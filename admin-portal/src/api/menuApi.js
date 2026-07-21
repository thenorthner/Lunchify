const BASE = "/api/menu";

/* FOOD */
export const addFoodMenu = (data) =>
  fetch(`${BASE}/food`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(data),
  }).then(res => res.json());

export const getFoodMenu = () =>
  fetch(`${BASE}/food`).then(res => res.json());

/* FRUIT */
export const addFruitMenu = (data) =>
  fetch(`${BASE}/fruit`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(data),
  }).then(res => res.json());

/* SNACKS */
export const addSnacksMenu = (data) =>
  fetch(`${BASE}/snacks`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(data),
  }).then(res => res.json());
