import React, { useState } from 'react';
import { AICallAgentType } from 'aliyun-auikit-aicall';
import { Button, Ellipsis, Mask } from 'antd-mobile';

import useCallStore from '@/Mobile/Call/store';

import { MaskCloseSVG, SubtitleMoreSVG, UserSVG } from './Icons';
import './subtitle.less';
import { getRootElement } from '@/common/utils';

function Subtitle() {
  const currentSubtitle = useCallStore((state) => state.currentSubtitle);
  const agentType = useCallStore((state) => state.agentType);
  const cameraMuted = useCallStore((state) => state.cameraMuted);

  const [detailVisible, setDetailVisible] = useState(false);

  if (!currentSubtitle || !currentSubtitle?.data.text) return null;

  let text = currentSubtitle.data.text;

  const onExpand = (e: React.MouseEvent) => {
    e.stopPropagation();
    setDetailVisible(true);
  };

  const rows = agentType === AICallAgentType.VisionAgent && cameraMuted ? 12 : 4;

  return (
    <div className='subtitle' onClick={(e) => e.stopPropagation()}>
      <div className='_source'>
        {currentSubtitle.source === 'agent' ? <div className='_agent-icon'></div> : UserSVG}
      </div>
      <div className='_text' onClick={onExpand}>
        <Ellipsis
          content={text}
          rows={rows}
          expandText={
            <span className='_more' onClick={(e) => e.stopPropagation()}>
              {SubtitleMoreSVG}
            </span>
          }
        />
      </div>
      <Mask
        visible={detailVisible}
        opacity='thick'
        className='subtitle-mask'
        onMaskClick={() => setDetailVisible(false)}
        getContainer={getRootElement}
      >
        <div className='_detail'>
          <div className='_detail-close'>
            <Button onClick={() => setDetailVisible(false)}>{MaskCloseSVG}</Button>
          </div>
          {text}
        </div>
      </Mask>
    </div>
  );
}

export default Subtitle;
