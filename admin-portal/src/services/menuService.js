import api from "./api";

export const saveFoodMenu = (date, items) =>
  api.post("/menu/food", { date, items });

export const saveSnacksMenu = (date, session, items) =>
  api.post("/menu/snacks", { date, session, items });

export const getFoodMenu = (date) =>
  api.get(`/menu/food?date=${date}`);

export const getSnacksMenu = (date, session) =>
  api.get(`/menu/snacks?date=${date}&session=${session}`);

export const saveFruitMenu = (date, items) =>
  api.post("/menu/fruit", { date, items });

export const getFruitMenu = (date) =>
  api.get(`/menu/fruit?date=${date}`);
