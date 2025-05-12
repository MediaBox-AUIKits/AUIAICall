import markdownit from 'markdown-it';

function wrapTable(md: markdownit) {
  const defaultOpenRender =
    md.renderer.rules.table_open ||
    function (tokens, idx, options, _, self) {
      return self.renderToken(tokens, idx, options);
    };
  md.renderer.rules.table_open = function (tokens, idx, options, env, self) {
    return `<div class="_table-container">` + defaultOpenRender(tokens, idx, options, env, self);
  };

  // 保存原始的 renderer 函数
  // save the original renderer
  const defaultCloseRender =
    md.renderer.rules.table_close ||
    function (tokens, idx, options, _, self) {
      return self.renderToken(tokens, idx, options);
    };

  md.renderer.rules.table_close = function (tokens, idx, options, env, self) {
    return defaultCloseRender(tokens, idx, options, env, self) + '</div>';
  };
}

export default wrapTable;
