import React, { useState } from 'react';
import classnames from 'classnames';
import SyntaxHighlighter from 'react-syntax-highlighter';
import { docco } from 'react-syntax-highlighter/dist/cjs/styles/hljs';
import { ChartRepository } from '../../types';
import NoData from '../common/NoData';
import ButtonCopyToClipboard from '../common/ButtonCopyToClipboard';
import styles from './ChartInstall.module.css';
import ExternalLink from '../common/ExternalLink';
import SmallTitle from '../common/SmallTitle';
import isUndefined from 'lodash/isUndefined';

interface Props {
  name: string;
  version?: string;
  repository: ChartRepository;
}

interface Tab {
  name: string;
  title: string;
}

const TABS: Tab[] = [
  {
    name: 'cli',
    title: 'Helm CLI',
  },
];
const ACTIVE_TAB: string = 'cli';

const ChartInstall = (props: Props) => {
  const [activeTab, setActiveTab] = useState(ACTIVE_TAB);

  if (isUndefined(props.version)) return null;

  return (
    <>
      <ul className={`nav nav-tabs ${styles.tabs}`}>
        {TABS.map((tab: Tab) => (
          <li className="nav-item" key={tab.name}>
            <button className={classnames(
                'btn btn-link nav-item',
                styles.btn,
                {[`active btn-primary ${styles.active}`]: tab.name === activeTab},
              )}
              onClick={() => setActiveTab(tab.name)}
            >
              {tab.title}
            </button>
          </li>
        ))}
      </ul>

      <div className="tab-content mt-3">
        {(() => {
          switch (activeTab) {
            case 'cli':
              const block1 = `helm repo add ${props.repository.name} ${props.repository.url}`;
              const block2 = `helm install ${props.repository.name}/${props.name} --version ${props.version}`;

              return (
                <div className="tab-pane fade show active">
                  <div className="d-flex justify-content-between mt-2 mb-2">
                    <SmallTitle text="Add repository" />
                    <div>
                      <ButtonCopyToClipboard text={block1} />
                    </div>
                  </div>

                  <SyntaxHighlighter language="bash" style={docco}>
                    {block1}
                  </SyntaxHighlighter>

                  <div className="d-flex justify-content-between mt-2 mb-2">
                    <SmallTitle text="Install chart" />
                    <div>
                      <ButtonCopyToClipboard text={block2} />
                    </div>
                  </div>

                  <SyntaxHighlighter language="bash" style={docco}>
                    {block2}
                  </SyntaxHighlighter>

                  <div className="mt-2">
                    <ExternalLink href="https://helm.sh/docs/intro/quickstart/" className="btn btn-link pl-0">
                      Need Helm?
                    </ExternalLink>
                  </div>
                </div>
              );
            default:
              return (
                <div className="tab-pane fade show active">
                  <NoData>Sorry, the information for Install is missing.</NoData>
                </div>
              );
          }
        })()}
      </div>
    </>
  );
};

export default ChartInstall;
