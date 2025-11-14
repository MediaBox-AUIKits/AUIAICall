import './index.less';

function VoiceAvatarImage({ url }: { url: string }) {
  return (
    <div className='voice-avatar-image'>
      <div className='_status'>
        <div></div>
      </div>
      <div className='_img'>
        <img src={url} />
      </div>
    </div>
  );
}

export default VoiceAvatarImage;
