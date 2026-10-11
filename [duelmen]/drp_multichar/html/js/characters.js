const CharacterScreen = (() => {
  let text = {};
  let genders = [];
  let jobs = [];
  let characters = [];
  let notice = "";
  let maxCharacters = 3;

  const post = async (name, data = {}) => {
    const response = await fetch(`https://${GetParentResourceName()}/${name}`, {
      method: "POST",
      body: JSON.stringify(data)
    });
    return response.json();
  };

  const slotCard = (slot) => {
    const character = characters.find((item) => Number(item.slot) === slot);
    if (!character) {
      return `<article class="card-in rounded-xl border border-dashed border-white/10 bg-black/10 p-5 flex flex-col min-h-56">
        <span class="text-xs text-white/30">SLOT ${slot}</span>
        <p class="text-sm text-white/35 mt-auto mb-4">${text.empty}</p>
        <button data-create="${slot}" class="w-full rounded-lg bg-cyan-300 py-2.5 text-sm font-bold text-slate-950 hover:bg-cyan-200">${text.create}</button>
      </article>`;
    }
    return `<article class="card-in rounded-xl border border-cyan-300/15 bg-white/[0.04] p-5 flex flex-col min-h-56">
      <div class="flex justify-between text-xs text-cyan-200/60"><span>SLOT ${slot}</span><span>${character.gender === "female" ? "♀" : "♂"}</span></div>
      <h2 class="font-display text-xl mt-5">${character.first_name} ${character.last_name}</h2>
      <p class="text-sm text-white/50 mt-2">${jobs.find((job) => job.value === character.job)?.label || character.job}</p>
      <p class="text-xs text-white/35 mt-1">Geboren: ${character.birth_date}</p>
      <button data-select="${slot}" class="mt-auto w-full rounded-lg border border-cyan-300/30 bg-cyan-300/10 py-2.5 text-sm text-cyan-100 hover:bg-cyan-300/20">${text.play}</button>
    </article>`;
  };

  const render = () => {
    const cards = Array.from({ length: maxCharacters }, (_, index) => index + 1).map(slotCard).join("");
    document.querySelector("#app").innerHTML = `<header class="flex items-center justify-between border-b border-white/10 px-7 py-6">
      <div><p class="text-xs tracking-[0.3em] text-cyan-300/60">GERMAN ROLEPLAY</p><h1 class="font-display text-2xl mt-2">${text.title}</h1><p class="text-sm text-white/40 mt-1">${text.subtitle}</p></div>
      <button id="close" class="rounded-lg border border-white/10 px-4 py-2 text-sm text-white/60 hover:text-white">${text.close} ×</button>
    </header><section class="grid gap-4 p-7 md:grid-cols-3">${cards}</section>
    ${notice ? `<p class="border-t border-rose-300/20 bg-rose-400/10 px-7 py-3 text-sm text-rose-200">${notice}</p>` : ""}`;
  };

  const form = (slot) => {
    const genderOptions = genders.map((item) => `<option value="${item.value}">${item.label}</option>`).join("");
    const jobOptions = jobs.map((item) => `<option value="${item.value}">${item.label}</option>`).join("");
    document.querySelector("#app").innerHTML = `<section class="p-7"><div class="flex justify-between"><div><p class="text-xs tracking-[0.3em] text-cyan-300/60">SLOT ${slot}</p><h1 class="font-display text-2xl mt-2">${text.create}</h1></div><button id="back" class="text-sm text-white/50 hover:text-white">${text.cancel}</button></div>
      <form id="characterForm" class="mt-7 grid gap-4 md:grid-cols-2">
        <label class="text-sm text-white/60">${text.firstName}<input name="firstName" maxlength="24" required class="mt-2 w-full rounded-lg border border-white/10 bg-white/5 px-4 py-3 text-white outline-none focus:border-cyan-300/60"></label>
        <label class="text-sm text-white/60">${text.lastName}<input name="lastName" maxlength="24" required class="mt-2 w-full rounded-lg border border-white/10 bg-white/5 px-4 py-3 text-white outline-none focus:border-cyan-300/60"></label>
        <label class="text-sm text-white/60">${text.birthDate}<input name="birthDate" type="date" min="1900-01-01" max="2010-12-31" required class="mt-2 w-full rounded-lg border border-white/10 bg-white/5 px-4 py-3 text-white outline-none"></label>
        <label class="text-sm text-white/60">${text.gender}<select name="gender" class="mt-2 w-full rounded-lg border border-white/10 bg-white/5 px-4 py-3 text-white outline-none">${genderOptions}</select></label>
        <label class="text-sm text-white/60 md:col-span-2">${text.job}<select name="job" class="mt-2 w-full rounded-lg border border-white/10 bg-white/5 px-4 py-3 text-white outline-none">${jobOptions}</select></label>
        <button class="md:col-span-2 rounded-lg bg-cyan-300 py-3 font-bold text-slate-950 hover:bg-cyan-200">${text.save}</button>
      </form></section>`;
    document.querySelector("#back").addEventListener("click", render);
    document.querySelector("#characterForm").addEventListener("submit", async (event) => {
      event.preventDefault();
      const data = Object.fromEntries(new FormData(event.target));
      data.slot = slot;
      const result = await post("create", data);
      if (result.ok) {
        characters = result.characters;
        notice = "";
        render();
      } else {
        notice = result.error || text.error;
        render();
      }
    });
  };

  const open = async (data) => {
    text = data.text;
    genders = data.genders;
    jobs = data.jobs;
    maxCharacters = Number(data.maxCharacters) || 3;
    document.body.classList.replace("opacity-0", "opacity-100");
    document.body.classList.replace("pointer-events-none", "pointer-events-auto");
    render();
    post("ready");
    const result = await post("load");
    if (result.ok) characters = result.characters;
    else notice = result.error;
    render();
  };

  document.addEventListener("click", async (event) => {
    const create = event.target.closest("[data-create]");
    const select = event.target.closest("[data-select]");
    if (create) form(Number(create.dataset.create));
    if (select) await post("select", { slot: Number(select.dataset.select) });
    if (event.target.closest("#close")) {
      await post("close");
      document.body.classList.replace("opacity-100", "opacity-0");
      document.body.classList.replace("pointer-events-auto", "pointer-events-none");
    }
  });

  return { open };
})();
