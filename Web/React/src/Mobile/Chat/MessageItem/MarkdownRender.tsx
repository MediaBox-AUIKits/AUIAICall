import markdownit from 'markdown-it';
import hljs from 'highlight.js';
import 'highlight.js/styles/github.css';

import { useEffect } from 'react';
import wrapTable from './markdownPlugin/wrapTable';
import addTargetToLinks from './markdownPlugin/addTargetToLinks';

import './markdownRender.less';
import { ImageViewer } from 'antd-mobile';
import { getRootElement } from '@/common/utils';

const md = markdownit({
  highlight: function (str, lang) {
    if (lang && hljs.getLanguage(lang)) {
      try {
        return hljs.highlight(str, { language: lang }).value;
        // eslint-disable-next-line @typescript-eslint/no-unused-vars
      } catch (__) {
        /** EMPTY */
      }
    }

    return ''; // use external default escaping
  },
});
md.use(wrapTable);
md.use(addTargetToLinks);

function MessageItemMarkdownRender({ text }: { text: string }) {
  useEffect(() => {
    if (text.includes('```')) {
      hljs.highlightAll();
    }
  }, [text]);

  const onMarkdownClick = (e: React.MouseEvent<HTMLDivElement>) => {
    e.stopPropagation();
    const target = e.target as HTMLImageElement;
    if (target.tagName === 'IMG') {
      const src = target.getAttribute('src');
      if (!src) return;
      ImageViewer.show({
        image: src,
        getContainer: getRootElement,
      });
    }
  };

  if (!text) return null;
  return (
    <div
      className='aicall-markdown-render'
      dangerouslySetInnerHTML={{
        __html: md.render(text),
      }}
      onClick={onMarkdownClick}
    />
  );
}

export default MessageItemMarkdownRender;
