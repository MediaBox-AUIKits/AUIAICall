import MarkdownIt from 'markdown-it';

function addTargetToLinks(md: MarkdownIt, target = '_blank') {
  // 存储原始的渲染函数
  const defaultRender =
    md.renderer.rules.link_open ||
    function (tokens, idx, options, _, self) {
      return self.renderToken(tokens, idx, options);
    };

  md.renderer.rules.link_open = function (tokens, idx, options, env, self) {
    // 获取 href 属性值
    const hrefIndex = tokens[idx].attrIndex('href');
    if (hrefIndex >= 0) {
      const href = tokens?.[idx].attrs?.[hrefIndex][1];

      // 可以在这里添加逻辑来决定是否添加 target 属性
      // 例如，只为外部链接添加 target 属性
      if (href && !href.startsWith('/') && !href.startsWith('#')) {
        // 添加 target 属性
        const aIndex = tokens[idx].attrIndex('target');
        if (aIndex < 0) {
          tokens[idx].attrPush(['target', target]);
        } else if (tokens[idx].attrs) {
          tokens[idx].attrs[aIndex][1] = target;
        }

        // 可选：添加 rel="noopener noreferrer" 以增加安全性
        const relIndex = tokens[idx].attrIndex('rel');
        if (relIndex < 0) {
          tokens[idx].attrPush(['rel', 'noopener noreferrer']);
        } else if (tokens[idx].attrs) {
          tokens[idx].attrs[relIndex][1] = 'noopener noreferrer';
        }
      }
    }

    // 通过默认渲染器渲染 token
    return defaultRender(tokens, idx, options, env, self);
  };
}

export default addTargetToLinks;
