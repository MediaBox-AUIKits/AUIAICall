import { JSONObject } from 'aliyun-auikit-aicall';

export interface RecordingController {
  sampleRate: number;
  stop: () => Promise<Float32Array[]>;
}

class AudioRecorder {
  private audioContext: AudioContext | null = null;
  private workletNode: AudioWorkletNode | null = null;
  private source: MediaStreamAudioSourceNode | null = null;
  private stream: MediaStream | null = null;

  async startRecording(): Promise<RecordingController> {
    try {
      if (!navigator.mediaDevices) {
        throw new Error('MediaDevices not supported');
      }

      // Get microphone access
      this.stream = await navigator.mediaDevices.getUserMedia({ audio: true });

      // Create audio context
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      this.audioContext = new (window.AudioContext || (window as any).webkitAudioContext)();

      // Create inline AudioWorkletProcessor
      const workletProcessorCode = `
        class AudioRecorderProcessor extends AudioWorkletProcessor {
          constructor() {
            super();
            this.audioData = [];
            this.recording = true;
            
            this.port.onmessage = (event) => {
              if (event.data === 'stop') {
                this.recording = false;
                this.port.postMessage({
                  eventType: 'recordedData',
                  audioBuffer: this.audioData
                });
              }
            };
          }

          process(inputs, outputs, parameters) {
            const inputChannel = inputs[0][0];
            
            if (inputChannel && this.recording) {
              this.audioData.push(new Float32Array(inputChannel));
            }
            
            // Copy input to output so we can hear the audio
            if (inputs[0].length > 0 && outputs[0].length > 0) {
              for (let i = 0; i < Math.min(inputs[0].length, outputs[0].length); i++) {
                if (inputs[0][i] && outputs[0][i]) {
                  outputs[0][i].set(inputs[0][i]);
                }
              }
            }
            
            return true;
          }
        }

        registerProcessor('audio-recorder-processor', AudioRecorderProcessor);
      `;

      // Create blob URL for the worklet processor
      const workletBlob = new Blob([workletProcessorCode], { type: 'application/javascript' });
      const workletUrl = URL.createObjectURL(workletBlob);

      // Add the module to the audio context
      await this.audioContext.audioWorklet.addModule(workletUrl);

      // Create nodes
      this.source = this.audioContext.createMediaStreamSource(this.stream);
      this.workletNode = new AudioWorkletNode(this.audioContext, 'audio-recorder-processor');

      // Connect nodes
      this.source.connect(this.workletNode);

      // Clean up the blob URL
      URL.revokeObjectURL(workletUrl);

      return {
        sampleRate: this.audioContext.sampleRate,
        stop: async (): Promise<Float32Array[]> => {
          return this.stopRecording();
        },
      };
    } catch (error) {
      console.error('Error starting recording:', error);
      throw error;
    }
  }

  private stopRecording(): Promise<Float32Array[]> {
    return new Promise((resolve) => {
      if (!this.workletNode || !this.source || !this.stream || !this.audioContext) {
        resolve([]);
        return;
      }

      // Listen for data from the worklet
      this.workletNode.port.onmessage = (event: MessageEvent) => {
        if (event.data.eventType === 'recordedData') {
          // Clean up resources
          this.workletNode?.disconnect();
          this.source?.disconnect();
          this.audioContext?.close();
          this.stream?.getTracks().forEach((track) => track.stop());

          resolve(event.data.audioBuffer);
        }
      };

      // Send stop message to worklet
      this.workletNode.port.postMessage('stop');
    });
  }
}

// Convert Float32Array to 16-bit integer array
function floatTo16BitPCM(input: Float32Array): Int16Array {
  const output = new Int16Array(input.length);
  for (let i = 0; i < input.length; i++) {
    const s = Math.max(-1, Math.min(1, input[i]));
    output[i] = s < 0 ? s * 0x8000 : s * 0x7fff;
  }
  return output;
}

// Create WAV file from audio data
export function encodeWAV(audioData: Float32Array[], sampleRate: number): DataView {
  // Calculate total length of audio data
  let dataLength = 0;
  for (const buffer of audioData) {
    dataLength += buffer.length;
  }

  const buffer = new ArrayBuffer(44 + dataLength * 2);
  const view = new DataView(buffer);

  // Helper function to write strings to DataView
  const writeString = (offset: number, string: string): void => {
    for (let i = 0; i < string.length; i++) {
      view.setUint8(offset + i, string.charCodeAt(i));
    }
  };

  // Merge audio buffers into single Float32Array
  const mergeBuffers = (): Float32Array => {
    const result = new Float32Array(dataLength);
    let offset = 0;
    for (const buffer of audioData) {
      result.set(buffer, offset);
      offset += buffer.length;
    }
    return result;
  };

  // WAV header
  writeString(0, 'RIFF');
  view.setUint32(4, 36 + dataLength * 2, true);
  writeString(8, 'WAVE');
  writeString(12, 'fmt ');
  view.setUint32(16, 16, true); // Sub-chunk size
  view.setUint16(20, 1, true); // Audio format (1 = PCM)
  view.setUint16(22, 1, true); // Number of channels
  view.setUint32(24, sampleRate, true); // Sample rate
  view.setUint32(28, sampleRate * 2, true); // Byte rate
  view.setUint16(32, 2, true); // Block align
  view.setUint16(34, 16, true); // Bits per sample
  writeString(36, 'data');
  view.setUint32(40, dataLength * 2, true); // Data chunk length

  // Write PCM data
  const floatData = mergeBuffers();
  const intData = floatTo16BitPCM(floatData);
  let offset = 44;
  for (let i = 0; i < intData.length; i++, offset += 2) {
    view.setInt16(offset, intData[i], true);
  }

  return view;
}

// Direct REST API approach
export const uploadBlobToOSSDirect = async (blob: Blob, fileName: string, ossConfig: JSONObject) => {
  // 如果不存在 window.OSS 加载 js
  // @ts-expect-error oss
  if (!window.OSS) {
    await new Promise<void>((resolve, reject) => {
      const ossScript = document.createElement('script');
      ossScript.src = 'https://gosspublic.alicdn.com/aliyun-oss-sdk-6.18.0.min.js';

      // 监听加载完成事件
      ossScript.onload = () => {
        resolve();
      };

      // 监听加载错误事件
      ossScript.onerror = () => {
        reject(new Error('Failed to load OSS SDK'));
      };

      document.head.appendChild(ossScript);
    });
  }

  // 确保 OSS 对象存在
  // @ts-expect-error oss
  if (!window.OSS) {
    throw new Error('OSS SDK failed to initialize');
  }

  // 现在可以安全地使用 OSS SDK
  // 创建 OSS 客户端
  // @ts-expect-error oss
  const client = new window.OSS({
    region: ossConfig.region as string,
    accessKeyId: ossConfig.access_key_id as string,
    accessKeySecret: ossConfig.access_key_secret as string,
    bucket: ossConfig.bucket as string,
    stsToken: ossConfig.sts_token as string, // 如果使用 STS
  });

  try {
    const url = `${ossConfig.base_path}/${fileName}`;
    // 上传文件
    await client.put(`${ossConfig.base_path}/${fileName}`, blob);
    return client.signatureUrl(url, { expires: 60 * 60 });
  } catch (error) {
    console.error('OSS upload failed:', error);
    throw error;
  }
};

export default AudioRecorder;
