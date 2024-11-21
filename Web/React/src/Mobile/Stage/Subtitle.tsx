import useCallStore from "@/common/store";
import { UserSVG } from "./Icons";
import "./subtitle.less";

function Subtitle() {
  const currentSubtitle = useCallStore((state) => state.currentSubtitle);
  if (!currentSubtitle || !currentSubtitle?.data.text) return null;

  return (
    <div className="subtitle">
      <div className="_source">
        {currentSubtitle.source === "agent" ? (
          <div className="_agent-icon"></div>
        ) : (
          UserSVG
        )}
      </div>
      <div className="_text">{currentSubtitle?.data.text}</div>
    </div>
  );
}

export default Subtitle;
