import React, { useState, CSSProperties } from 'react';

interface ResizableContainerProps {
  children: React.ReactNode;
  title: string;
  defaultHeight?: number;
  minHeight?: number;
}

interface Styles {
  wrapper: CSSProperties;
  container: CSSProperties;
  header: CSSProperties;
  headerTitle: CSSProperties;
  content: CSSProperties;
  resizeHandle: CSSProperties;
  resizeHandleDragging: CSSProperties;
}

const styles: Styles = {
  wrapper: {
    width: '100%',
    maxWidth: '1152px',
    marginLeft: 'auto',
    marginRight: 'auto',
    //marginTop: '16px',
    marginBottom: '16px'
  },
  container: {
    position: 'relative',
    width: '100%',
    border: '1px solid',
    borderRadius: '0.5rem',
    overflow: 'hidden',
    //transition: 'height 300ms ease-in-out'
  },
  header: {
    height: '24px',
    padding: '0 8px',
    borderBottom: '1px solid',
    display: 'flex',
    alignItems: 'center',
    cursor: 'pointer',
    userSelect: 'none'
  },
  headerTitle: {
    fontSize: '14px',
    fontWeight: 500,
    overflow: 'hidden',
    textOverflow: 'ellipsis',
    whiteSpace: 'nowrap'
  },
  content: {
    height: '100%'
  },
  resizeHandle: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    height: '8px',
    cursor: 'ns-resize'
  },
  resizeHandleDragging: {
    backgroundColor: 'rgba(0, 0, 0, 0.1)'
  }
};

const ResizableContainer: React.FC<ResizableContainerProps> = ({
  children,
  title,
  defaultHeight = 300,
  minHeight = 100,
}) => {
  const [isDragging, setIsDragging] = useState<boolean>(false);
  const [height, setHeight] = useState<number>(defaultHeight);
  const [isCollapsed, setIsCollapsed] = useState<boolean>(false);
  const [previousHeight, setPreviousHeight] = useState<number>(defaultHeight);

  const handleMouseDown = (e: React.MouseEvent<HTMLDivElement>) => {
    e.preventDefault();
    if (isCollapsed) return;
    setIsDragging(true);
    
    const startY = e.clientY;
    const startHeight = height;
    
    const handleMouseMove = (moveEvent: MouseEvent) => {
      const deltaY = moveEvent.clientY - startY;
      const newHeight = Math.max(minHeight, startHeight + deltaY);
      setHeight(newHeight);
    };
    
    const handleMouseUp = () => {
      setIsDragging(false);
      document.removeEventListener('mousemove', handleMouseMove);
      document.removeEventListener('mouseup', handleMouseUp);
    };
    
    document.addEventListener('mousemove', handleMouseMove);
    document.addEventListener('mouseup', handleMouseUp);
  };

  const handleToggleCollapse = () => {
    if (isCollapsed) {
      setHeight(previousHeight);
    } else {
      setPreviousHeight(height);
      setHeight(24);
    }
    setIsCollapsed(!isCollapsed);
  };

  return (
    <div style={styles.wrapper}>
      <div 
        style={{
          ...styles.container,
          height: `${height}px`
        }}
      >
        <div 
          onClick={handleToggleCollapse}
          style={styles.header}
        >
          <div style={styles.headerTitle}>
            {title}
          </div>
        </div>

        <div style={{
          ...styles.content,
          display: isCollapsed ? 'none' : 'block'
        }}>
          {children}
        </div>
        
        {!isCollapsed && (
          <div
            style={{
              ...styles.resizeHandle,
              ...(isDragging ? styles.resizeHandleDragging : {})
            }}
            onMouseDown={handleMouseDown}
          />
        )}
      </div>
    </div>
  );
};

export default ResizableContainer;