const navItems = document.querySelectorAll('.nav-item');
const content = document.getElementById('content');
const terminalBody = document.getElementById('terminal-body');

const sections = {
  overview: {
    title: 'Desktop shell preview',
    description:
      'High-level snapshot of the AI desktop shell direction. Use this space to validate layout, motion, and Mint-inspired visuals before wiring services.',
    bullets: [
      'Cinnamon-friendly theming with green highlights and glass panels.',
      'Wallpaper hosts a floating terminal mock for the AI command layer.',
      'Navigation will expand to workspaces, launchers, and agent settings.',
    ],
    terminal: [
      'aether@mint ➜ shell status: prototype',
      'aether@mint ➜ ai-core link: pending',
      'aether@mint ➜ workspace tiles: loading stubs',
    ],
  },
  workspace: {
    title: 'Workspace layout',
    description:
      'Interactive zones for app tiles, assistant cards, and quick actions. The final shell will let users pin widgets next to the AI terminal.',
    bullets: [
      'Grid-ready canvas for apps and assistant tiles.',
      'Accent states mirror Mint with subtle gradients and rounded corners.',
      'Terminal stays docked to keep the command layer always visible.',
    ],
    terminal: [
      'aether@mint ➜ loading workspace canvas',
      'aether@mint ➜ pinning assistant cards...',
      'aether@mint ➜ new tile: system monitor stub',
    ],
  },
  settings: {
    title: 'Theme and system settings',
    description:
      'Controls for wallpaper, shell color scheme, and AI connectivity. This space will also surface metrics for GPU/CPU and model runtimes.',
    bullets: [
      'Toggle Mint-inspired dark theme and accent intensity.',
      'Configure local/remote AI endpoints for shell commands.',
      'Preview telemetry widgets for resource usage.',
    ],
    terminal: [
      'aether@mint ➜ applying mint-dark theme',
      'aether@mint ➜ telemetry daemon: awaiting signal',
      'aether@mint ➜ configs stored in ~/.aetheros',
    ],
  },
};

function renderSection(key) {
  const section = sections[key];
  if (!section) return;

  navItems.forEach((item) => {
    item.classList.toggle('active', item.dataset.section === key);
  });

  content.innerHTML = `
    <h1>${section.title}</h1>
    <p>${section.description}</p>
    <ul>
      ${section.bullets.map((bullet) => `<li>${bullet}</li>`).join('')}
    </ul>
  `;

  terminalBody.innerHTML = section.terminal
    .map(
      (line) => `<div class="line"><span class="prompt">aether@mint ➜</span> ${line.replace('aether@mint ➜ ', '')}</div>`
    )
    .join('');
}

navItems.forEach((item) => {
  item.addEventListener('click', () => renderSection(item.dataset.section));
});

renderSection('overview');
