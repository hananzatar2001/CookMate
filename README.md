# CookMate
CookMate 🍽️ is a mobile app for your personal cooking. It offers smart recipe suggestions, ingredient substitutions, meal planning, and calorie tracking. Users can filter recipes based on their needs, upload their own, and receive notifications of new recipes. Cook smart, eat healthy!

## Features

-  **Recipe Discovery**: Browse and search personalized recipe suggestions.
-  **Upload Your Recipes**: Add your own meals with ingredients, steps, and nutritional info.
-  **Meal Planner**: Schedule recipes into daily meal plans.
-  **Calorie Tracker**: Log your intake and monitor macronutrients.
-  **Ingredient Substitution**: Find healthy alternatives for ingredients.
-  **Favorites**: Save your go-to recipes for quick access.

## How to Run

-  **1- Clone the repository:**:
  `git clone https://github.com/hananzatar2001/CookMate.git`
-  **2- Navigate to the project:**:
  `cd CookMate`
-  **3- Install dependencies:**:
   `flutter pub get`
-  **4- Run the app:**:
   `flutter run`
  
## Description of each page

**Database**
-  The database was created using Firebase. All information is saved except for the images.
   `https://firebase.google.com/`
-  We used cloudinary to save the images and link them to Firebase.
  `https://cloudinary.com/`

**Calorie Tracking**
-  On this page, the user's calories are displayed, along with the calories he has consumed.
-  The user's calorie needs are calculated based on their gender, age, weight, and height.
-  For men:
   `BMR = 10 x weight + 6.25 x height - 5 x age + 5.`
-  For women:
   `BMR = 10 x weight + 6.25 x height - 5 x age - 161`
   
-  The nutrition taken from meals that day is also shown.
   
**Meal planning**
-  This page displays the meals the user consumed on any day they specify using the calendar and the type.

**Recipe Upload**
-  On this page, the user can attach any recipe they want. The recipe image can be uploaded from the album.
-  Select the ingredients from the API.
-  This API was used.
  `https://spoonacular.com/food-api`
-  Then, select the type of meal.
-  And the date the meal was consumed.
-  Then, you can upload it.
  
**Setting screen**
- On the settings page, user data is saved and can also be modified.

**hamburger menu**
- In the burger menu, navigation to several pages is facilitated. You can also log out.
  
**Shopping List**
-  It allows the user to add the purchases he needs on this page, with the ability to mark the purchases that have been brought.

**name page**
-  Recipe explanation:
-  `Code or link`

  
**Authentication**
-  **4- Run the app:**:
  `flutter run`

**Home Screen**
-  **4- Run the app:**:
   `flutter run`

**Splash1 Screen**
-  **4- Run the app:**:
   `flutter run`
  
**Splash2 Screen**
-  **4- Run the app:**:
   `flutter run`

**saved recipes**
-  **4- Run the app:**:
   `flutter run`
  
**User Profile**
-  **4- Run the app:**:
-  `flutter run`

  
**NavigationBar**
-  **4- Run the app:**:
-  `flutter run`

**name page**
-  **4- Run the app:**:
-  `flutter run`
  
**name page**
-  **4- Run the app:**:
-  `flutter run`

**name page**
-  **4- Run the app:**:
-  `flutter run`
  
**name page**
-  **4- Run the app:**:
-  `flutter run`

**name page**
-  **4- Run the app:**:
-  `flutter run`
  
**name page**
-  **4- Run the app:**:
-  `flutter run`

**name page**
-  **4- Run the app:**:
-  `flutter run`
  
**name page**
-  **4- Run the app:**:
-  `flutter run`


## Team
- Hanan Zatar – Database ,Calorie Tracking ,Meal planning ,Recipe Upload ,Setting screen ,hamburger menu and Shopping List 

- Eman – Splash1 Screen, Splash2 Screen, Authentication(Log in, Signup) , Home page, saved recipes , User Profile , NavigationBar

- Rahaf – Calorie Tracker, Planner & Settings

- Dana – Settings ,Meal planning ,Calorie Tracking ,Ingredient Substitution ,Home Screen
