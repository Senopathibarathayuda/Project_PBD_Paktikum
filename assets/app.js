(() => {
  const sidebar = document.querySelector('#sidebar');
  const backdrop = document.querySelector('#sidebar-backdrop');
  const open = document.querySelector('#menu-toggle');
  const closeDrawer = () => {
    sidebar?.classList.remove('is-open');
    backdrop?.classList.remove('is-visible');
    open?.setAttribute('aria-expanded', 'false');
  };
  open?.addEventListener('click', () => {
    const on = !sidebar?.classList.contains('is-open');
    sidebar?.classList.toggle('is-open', on);
    backdrop?.classList.toggle('is-visible', on);
    open?.setAttribute('aria-expanded', String(on));
  });
  backdrop?.addEventListener('click', closeDrawer);
  document.addEventListener('keydown', (event) => {
    if (event.key === 'Escape') closeDrawer();
  });
  document.querySelectorAll('[data-confirm]').forEach((form) => {
    form.addEventListener('submit', (event) => {
      if (!window.confirm(form.dataset.confirm)) event.preventDefault();
    });
  });
  document.querySelectorAll('[data-table-filter]').forEach((input) => {
    const table = document.getElementById(input.dataset.tableFilter);
    if (!table) return;
    const rows = Array.from(table.tBodies[0]?.rows || []);
    input.addEventListener('input', () => {
      const query = input.value.trim().toLocaleLowerCase('id');
      rows.forEach((row) => {
        row.hidden = !row.textContent.toLocaleLowerCase('id').includes(query);
      });
    });
  });
})();
