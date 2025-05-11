

 users
{
  "user_id": "string ",
  "name": "string",
  "email": "string",
  "password_hash": "string",
  "profile_picture": "string (URL)",
  
}
 
 recipes
{
  "user_id": "reference to users/{userId}",
  "recipe_id": "reference to recipes/{recipeId}",
  "title": "string",
  "description": "string",
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

 favorites
{
  "favorite_id": "string ",
  "user_id": "reference to users/{userId}",
  "recipe_id": "reference to recipes/{recipeId}",
  "favorited_at": "timestamp"
}

 mealPlans
{
 "plan_id": "string ",
  "user_id": "reference to users/{userId}",
  "recipe_id": "reference to recipes/{recipeId}",
  "meal_type": "string (breakfast | lunch | dinner | snack)",
  "date_scheduled": "timestamp"
}

 calorieLogs
{
  "log_id": "reference to users/{userId}",
  "recipe_id": "reference to recipes/{recipeId}",
  "meal_type": "string (breakfast | lunch | dinner | snack)",
  "Calories taken": "number",
  "Actual calories": "number",
  "log_id": "string",
  "log_date": "timestamp",
  "created_at": "timestamp"
}

 notifications
{
 "notification_id": "string ",
  "user_id": "reference to users/{userId}",
  "title": "string",
  "body": "string",
  "is_read": "boolean",
  "sent_at": "timestamp"
}

 userCaloriesNeeded

{
  "user_id": "reference to users/{userId}",
  "calories": "number",
  "protein": "number",
  "carbs": "number",
  "fats": "number"
}
