window.addEventListener("message", (event) => {
  const { action, data } = event.data;
  if (action === "open") CharacterScreen.open(data);
});

document.addEventListener("keydown", async (event) => {
  if (event.key !== "Escape") return;
  await fetch(`https://${GetParentResourceName()}/close`, {
    method: "POST",
    body: JSON.stringify({})
  });
  document.body.classList.replace("opacity-100", "opacity-0");
  document.body.classList.replace("pointer-events-auto", "pointer-events-none");
});
