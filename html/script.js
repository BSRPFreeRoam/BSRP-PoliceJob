const fp = document.getElementById('fingerprint');
const resource = typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'bsrp-policejob';

window.addEventListener('message', (e) => {
  const msg = e.data || {};
  if (msg.action === 'fingerprint') {
    const d = msg.data || {};
    document.getElementById('fpName').textContent = d.name || '—';
    document.getElementById('fpCid').textContent = d.cid != null ? String(d.cid) : '—';
    document.getElementById('fpId').textContent = d.id || '—';
    document.getElementById('fpJob').textContent = d.job || '—';
    fp.classList.remove('hidden');
  }
  if (msg.action === 'closeFingerprint') {
    fp.classList.add('hidden');
  }
});

document.getElementById('fpClose').addEventListener('click', () => {
  fp.classList.add('hidden');
  fetch(`https://${resource}/closeFingerprint`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: '{}',
  });
});

document.addEventListener('keydown', (e) => {
  if (e.key === 'Escape' && !fp.classList.contains('hidden')) {
    document.getElementById('fpClose').click();
  }
});
