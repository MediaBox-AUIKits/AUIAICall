import React from 'react';

function MessageItemTextLineRender({ text }: { text: string }) {
  if (!text) return null;
  // 将文本中的换行符替换为 JSX 可识别的 <br /> 标签
  // replace \n with <br />
  const formattedText = text.split('\n').map((line, index) => (
    <React.Fragment key={index}>
      {line}
      <br />
    </React.Fragment>
  ));

  return <div className='aicall-text-render'>{formattedText}</div>;
}

export default MessageItemTextLineRender;
