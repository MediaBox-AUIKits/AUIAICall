import React from 'react';

function MessageItemTextLineRender({ text }: { text: string }) {
  if (!text) return null;
  // 将文本中的换行符替换为 JSX 可识别的 <br /> 标签
  const formattedText = text.split('\n').map((line, index) => (
    <React.Fragment key={index}>
      {line}
      <br />
    </React.Fragment>
  ));

  return <>{formattedText}</>;
}

export default MessageItemTextLineRender;
