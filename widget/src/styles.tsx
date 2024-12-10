import type { CSSProperties } from 'react';

interface StyleDictionary {
  [key: string]: CSSProperties;
}

export const styles: StyleDictionary = {
  container: {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    width: '100%'
  },
};