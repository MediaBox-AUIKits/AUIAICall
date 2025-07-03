import markdownit from 'markdown-it';
import hljs from 'highlight.js';
import 'highlight.js/styles/github.css';

import { useEffect } from 'react';
import wrapTable from './markdownPlugin/wrapTable';
import addTargetToLinks from './markdownPlugin/addTargetToLinks';
import codeWithHeader from './markdownPlugin/codeWithHeader';

import './markdownRender.less';
import { ImageViewer, Toast } from 'antd-mobile';
import { copyText, getRootElement } from '@/common/utils';
import { getText, useTranslation } from '@/common/i18nContext';

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
md.use(wrapTable, getText('chat.message.tableTitle'));
md.use(addTargetToLinks);
md.use(codeWithHeader);

function MessageItemMarkdownRender({ text }: { text: string }) {
  const { t } = useTranslation();

  useEffect(() => {
    if (text.includes('```')) {
      hljs.highlightAll();
    }
  }, [text]);

  const onMarkdownClick = async (e: React.MouseEvent<HTMLDivElement>) => {
    e.stopPropagation();
    const target = e.target as HTMLElement;
    if (target.tagName === 'IMG') {
      const src = target.getAttribute('src');
      if (!src) return;
      ImageViewer.show({
        image: src,
        getContainer: getRootElement,
      });
    } else if (target.tagName === 'BUTTON') {
      let content = '';
      if (target.className.includes('_copy-btn')) {
        content = target.getAttribute('data-content') || '';
      } else if (target.className.includes('_table-copy-btn')) {
        const tableContainer = target.closest('._table-container') as HTMLElement;
        const rows = tableContainer.querySelectorAll('tr');
        const result: string[] = [];
        rows.forEach((row) => {
          const rowData: string[] = [];
          const cells = row.querySelectorAll('th, td');

          cells.forEach((cell) => {
            rowData.push((cell.textContent || '').trim());
          });
          if (rowData.length > 0) {
            result.push(rowData.join('\t'));
          }
        });

        content = result.join('\n');
      }

      if (content) {
        try {
          await copyText(content);
          Toast.show({ content: t('chat.message.copied'), getContainer: getRootElement });
        } catch (error) {
          console.warn(error);
          Toast.show({ content: t('chat.message.copyFailed'), getContainer: getRootElement });
        }
      }
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
