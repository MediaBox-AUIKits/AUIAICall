import MarkdownIt from 'markdown-it';
function codeWithHeader(md: MarkdownIt) {
  // 添加复制按钮功能
  const defaultFence = md.renderer.rules.fence;
  md.renderer.rules.fence = function (tokens, idx, options, env, self) {
    const codeHtml = defaultFence?.(tokens, idx, options, env, self);

    const token = tokens[idx];
    // 获取语言标识符（如果有多个空格分隔的词，只取第一个）
    const language = token.info.trim().split(/\s+/)[0] || '';
    const content = tokens[idx].content.replace(new RegExp('"', 'g'), '&quot;').replace(new RegExp("'", 'g'), '&apos;');

    return `
      <div class="_code-wrapper">
        <div class="_code-header">
          <span class="_code-language">${language}</span>
          <button class="_btn _copy-btn" data-content="${content}"><svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" fill="none" version="1.1" width="20" height="20" viewBox="0 0 20 20"><defs><clipPath id="master_svg0_1105_088580"><rect x="0" y="0" width="20" height="20" rx="0"/></clipPath></defs><g clip-path="url(#master_svg0_1105_088580)"><g><path d="M16.136400000000002,14.7396L14.0909,14.7396C13.7159,14.7396,13.4091,14.4349,13.4091,14.0625C13.4091,13.6901,13.7159,13.3854,14.0909,13.3854L15.7955,13.3854C16,13.3854,16.136400000000002,13.25,16.136400000000002,13.0469L16.136400000000002,3.56771C16.136400000000002,3.36458,16,3.22917,15.7955,3.22917L8.97727,3.22917C8.77273,3.22917,8.63636,3.36458,8.63636,3.56771L8.63636,3.90625C8.63636,4.27865,8.329550000000001,4.58333,7.95455,4.58333C7.57955,4.58333,7.27273,4.27865,7.27273,3.90625L7.27273,3.22917C7.27273,2.484375,7.88636,1.875,8.63636,1.875L16.136400000000002,1.875C16.886400000000002,1.875,17.5,2.484375,17.5,3.22917L17.5,13.3854C17.5,14.1302,16.886400000000002,14.7396,16.136400000000002,14.7396ZM12.7273,6.61458L12.7273,16.7708C12.7273,17.5156,12.11364,18.125,11.36364,18.125L3.86364,18.125C3.113636,18.125,2.5000000780279,17.5156,2.5000000780279,16.7708L2.5,6.61458C2.5,5.86979,3.113636,5.26042,3.86364,5.26042L11.36364,5.26042C12.11364,5.26042,12.7273,5.86979,12.7273,6.61458ZM11.02273,6.61458L4.20455,6.61458C4,6.61458,3.86364,6.75,3.86364,6.95312L3.86364,16.432299999999998C3.86364,16.6354,4,16.7708,4.20455,16.7708L11.02273,16.7708C11.22727,16.7708,11.36364,16.6354,11.36364,16.432299999999998L11.36364,6.95312C11.36364,6.75,11.22727,6.61458,11.02273,6.61458Z" fill="#26244C" fill-opacity="1" style="mix-blend-mode:passthrough"/></g></g></svg></button>
        </div>
      ${codeHtml}
      </div>
    `;
  };
}

export default codeWithHeader;
