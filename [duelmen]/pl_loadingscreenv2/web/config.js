/**
 * ============================================================
 *  Loading Screen — Configuration
 *  Edit everything here. No changes needed in other files.
 * ============================================================
 */

const CONFIG = {

  /* ----------------------------------------------------------
   *  SERVER IDENTITY
   * ---------------------------------------------------------- */
  server: {
    name:     'DÜLMEN ROLEPLAY',
    tagline:  'Deine Geschichte. Deine Stadt.',
    subtitle: 'German Custom Roleplay Experience',
    logo:     '',                      // Add your future logo at assets/logo.png, then restore this path.
  },

  /* ----------------------------------------------------------
   *  BACKGROUND VIDEO
   * ---------------------------------------------------------- */
  background: {
    video:          'assets/background.mp4',   // MP4 or WebM path
    fallbackColor:  '#080c14',                 // Shown if video fails
    overlayOpacity: 0.68,                      // 0 = transparent, 1 = black
  },

  /* ----------------------------------------------------------
   *  THEME COLORS
   *  All UI elements derive from these values automatically.
   * ---------------------------------------------------------- */
  theme: {
    primary:        '#c8a96e',          // Gold accent — buttons, bar, glows
    accent:         '#e8c87a',          // Lighter gold — gradients, highlights
    background:     '#080c14',          // Deep dark fallback
    textHighlight:  '#c8a96e',          // Inline highlighted text color
    overlayTint:    'rgba(5,8,18,0.55)',// Extra darkening gradient layer
  },

  /* ----------------------------------------------------------
   *  MUSIC PLAYER
   * ---------------------------------------------------------- */
  music: {
    autoplay:      true,
    defaultVolume: 0.25,         // 0.0 – 1.0
    playlist: [
      {
        title:     'Fearless Funk',
        artist:    'DR MØB, Chris Linton',
        src:       'assets/music/music1.mp3',
        thumbnail: 'assets/music/music1.png',            // Optional cover image path
      },
      {
        title:     'Vandali',
        artist:    'Aditya Sharma',
        src:       'assets/music/music2.mp3',
        thumbnail: 'assets/music/music2.png',
      },
    ],
  },

  /* ----------------------------------------------------------
   *  STAFF PANEL
   * ---------------------------------------------------------- */
  staff: {
    enabled: true,
    title:   'DÜLMEN TEAM',
    members: [],
  },

  /* ----------------------------------------------------------
   *  SOCIAL LINKS
   *  platform: 'discord' | 'youtube' | 'instagram' | 'twitter'
   * ---------------------------------------------------------- */
  social: {
    links: [],
  },

  /* ----------------------------------------------------------
   *  LOADING BAR
   * ---------------------------------------------------------- */
  loading: {
    text:         'Verbindung mit Dülmen Roleplay wird hergestellt…',
    completeText: 'Willkommen bei Dülmen Roleplay',
    showPercent:  true,
  },

  /* ----------------------------------------------------------
   *  SECTION TOGGLES
   *  Set false to completely hide a section.
   * ---------------------------------------------------------- */
  sections: {
    showLogo:     true,
    showStaff:    false,
    showMusic:    true,
    showSocial:   false,
    showControls: true,
  },

  /* ----------------------------------------------------------
   *  SERVER KEYBINDS
   *  Displayed in the controls panel when the player clicks
   *  "Show Controls". Add, remove, or reorder freely.
   * ---------------------------------------------------------- */
  controls: [
    { key: 'TAB', label: 'Inventar'      },
    { key: 'F10', label: 'HUD ein/aus'   },
    { key: 'F8',  label: 'FiveM-Konsole' },
  ],

};
