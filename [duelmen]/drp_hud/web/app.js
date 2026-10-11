const hud = document.getElementById('hud');
const money = new Intl.NumberFormat('de-DE', { style: 'currency', currency: 'EUR', maximumFractionDigits: 0 });
const circumference = 97.39;

function setRing(id, value) {
  const safe = Math.max(0, Math.min(100, Number(value) || 0));
  document.getElementById(id).style.strokeDashoffset = `${circumference - (circumference * safe / 100)}`;
}

window.addEventListener('message', ({ data }) => {
  if (data.action === 'visibility') {
    hud.classList.toggle('hidden', !data.visible);
    return;
  }

  if (data.action === 'economy') {
    document.getElementById('character-name').textContent = data.data.name || 'Unknown';
    document.getElementById('cash').textContent = money.format(data.data.cash || 0);
    document.getElementById('bank').textContent = money.format(data.data.bank || 0);
    document.getElementById('job').textContent = (data.data.job || 'unemployed').replace(/_/g, ' ');
    return;
  }

  if (data.action === 'status') {
    setRing('health-fill', data.health); setRing('armour-fill', data.armour);
    setRing('hunger-fill', data.hunger); setRing('thirst-fill', data.thirst); setRing('stamina-fill', data.stamina);
    const voice = document.getElementById('voice');
    voice.classList.toggle('talking', Boolean(data.talking));
    voice.textContent = data.talking ? '● SPRICHT' : '● NORMAL';
    document.getElementById('street').textContent = data.street || 'Los Santos';
    document.getElementById('time').textContent = data.time || '00:00';
    document.getElementById('speed').textContent = data.speed || 0;
    document.getElementById('vehicle').classList.toggle('active', Boolean(data.inVehicle));
  }
});
