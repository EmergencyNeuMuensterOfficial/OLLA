const app = document.querySelector('#app');
const list = document.querySelector('#character-list');
const status = document.querySelector('#status');
const createForm = document.querySelector('#create-form');
const showCreate = document.querySelector('#show-create');
let maxCharacters = 3;

async function post(name, data = {}) {
  const response = await fetch(`https://${GetParentResourceName()}/${name}`, { method: 'POST', headers: { 'Content-Type': 'application/json; charset=UTF-8' }, body: JSON.stringify(data) });
  return response.json();
}

function render(characters) {
  list.innerHTML = '';
  characters.forEach(character => {
    const card = document.createElement('div'); card.className = 'card';
    card.innerHTML = `<div class="card-info"><strong>${escapeHtml(character.first_name)} ${escapeHtml(character.last_name)}</strong><span>${character.gender === 'female' ? 'Female' : 'Male'} · Born ${escapeHtml(character.date_of_birth)}</span></div><button class="primary">Play</button><button class="delete">Delete</button>`;
    const [play, remove] = card.querySelectorAll('button');
    play.onclick = () => post('selectCharacter', { id: character.id });
    remove.onclick = () => { if (confirm(`Delete ${character.first_name} ${character.last_name}?`)) post('deleteCharacter', { id: character.id }); };
    list.appendChild(card);
  });
  showCreate.classList.toggle('hidden', characters.length >= maxCharacters);
  if (!characters.length) status.textContent = 'Create your first character to enter Los Santos.';
}

function escapeHtml(value) { const d = document.createElement('div'); d.textContent = value ?? ''; return d.innerHTML; }
window.addEventListener('message', event => {
  const data = event.data;
  if (data.action === 'open') { app.classList.remove('hidden'); maxCharacters = data.maxCharacters || 3; createForm.classList.add('hidden'); render(data.characters || []); if (data.error) status.textContent = data.error; }
  if (data.action === 'close') app.classList.add('hidden');
});
showCreate.onclick = () => createForm.classList.remove('hidden');
document.querySelector('#cancel-create').onclick = () => createForm.classList.add('hidden');
createForm.onsubmit = event => { event.preventDefault(); const data = Object.fromEntries(new FormData(createForm)); post('createCharacter', data); };
