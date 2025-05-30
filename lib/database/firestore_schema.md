
User
{
  "user_id": "string ",
  "name": "string",
  "email": "string",
  "password_hash": "string",
  "profile_picture": "string (URL)",
  "Age": "number",
  "Weight": "number",
  "Gender":"string",
  "Height": "number",
  "CaloriesNeeded": "number",
  "Specific allergies":"string",
  "Diseases":"string",
  "Are you a vegetarian?":"boolean"
  
}

Recipes
{
  "user_id": "reference to users/{userId}",
  "recipe_id": "reference to recipes/{recipeId}",
  "title": "string",
  "calories": "number",
  "Protein": "number",
  "Carbs": "number",
  "Fats": "number",
  "steps": ["string"],
  "Ingredients": ["string"],
  "image_url": "string (URL)",
  "video_url": "string (URL)",
  "created_at": "timestamp"
}

Favorites
{
  "favorite_id": "string ",
  "user_id": "reference to users/{userId}",
  "recipe_id": "reference to recipes/{recipeId}",
  "favorited_at": "timestamp"
}

MealPlans
{
 "plan_id": "string ",
  "user_id": "reference to users/{userId}",
  "recipe_id": "reference to recipes/{recipeId}",
  "meal_type": "string (breakfast | lunch | dinner | snack)",
  "date_scheduled": "timestamp"
}

 CalorieLogs
{
  "recipe_id": "reference to recipes/{recipeId}",
  "meal_type": "string (breakfast | lunch | dinner | snack)",
  "Calories taken": "number",
  "Actual calories": "number",
  "log_id": "string",
  "log_date": "timestamp",
  "created_at": "timestamp"
  "user_id": /users/user_id

}

Notifications
{
 "notification_id": "string ",
  "user_id": "reference to users/{userId}",
  "title": "string",
  "body": "string",
  "is_read": "boolean",
  "sent_at": "timestamp"
}

UserCaloriesNeeded

{
  "user_id": "reference to users/{userId}",
  "calories": "number",
  "protein": "number",
  "carbs": "number",
  "fats": "number"
}

 ShoppingList

{
  "user_id": "reference to users/{userId}",
  "products": ["string"]
}
SaveRecipes

{
"user_id": "reference to users/{userId}",
"recipe_id": "reference to recipes/{recipeId}"
"save_at": "timestamp",
"save_id": "string "
}