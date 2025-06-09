# CookMate
CookMate 🍽️ is a mobile app for your personal cooking. It offers smart recipe suggestions, ingredient substitutions, meal planning, and calorie tracking. Users can filter recipes based on their needs, upload their own, and receive notifications of new recipes. Cook smart, eat healthy!

## Features:

-  **Authentication**:A secure login and registration system with Firebase Authentication and encrypted password storage. Sessions are maintained using SharedPreferences.
-  **Sign Up Page**:Allows users to create an account by entering their name, email, and password. It prevents duplicate emails and securely stores user information.
-  **Login Page**:Authenticates users via email/password, validates entries, and redirects to the home screen if successful.
-  **Session Handler**:Automatically validates a stored user session upon launch and redirects to the appropriate screen without repeating logins.
-  **Forgot Password Dialog**:Allows users to reset their password by entering their email. It sends a reset link via Firebase and displays the status via the SnackBar.
-  **Home Screen**:Serves as the main dashboard after login, displaying the current date, greeting, daily calorie goal via a radial gauge, and personalized food recommendations.
-  **Splash1 Screen**:The app's first welcome screen. It displays the CookMate branding and a description with a call to action that transitions to the quote screen.
-  **Splash2 Screen**:An animated motivational quote layer displayed before logging in. It features a call to action button that leads to the authentication process.
-  **Saved Recipes Screen**:Displays the user's saved recipes. It includes filtering by category and a tap-to-view feature for detailed recipe information.
-  **User Profile**:View and edit user information through settings and a profile picture. It categorizes uploaded, saved, and favorite recipes, with counters.
-  **Navigation Bar**:A bottom navigation bar that provides seamless access to the Home, Saved Recipes, and Profile sections. Highlight the current page with custom icons.
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
-  ### 🔔 Rahaf – Notifications Screen
Displays user-specific notifications fetched from Firebase. Includes recipe reminders and alerts tailored to the user.

---

### ⭐ Favorites Page
Displays all recipes marked as favorites by the user. Users can:
- View detailed recipe information
- Remove from favorites
- Share or set alerts

---

### 🔍 Discovery Recipes Page
Shows recipes fetched from:
- Spoonacular API
- User-uploaded recipes from Firebase  
Includes:
- Search functionality
- Infinite scrolling to explore more recipes
- Clean grid layout

---

### 🧂 Ingredients Recipe Page
Displays ingredients for a selected recipe.  
If the recipe is from the API, possible ingredient substitutes are also shown.

---

### 📖 Steps Page
Provides detailed cooking instructions for the selected recipe.  
Structured in a step-by-step format to enhance the cooking experience.

---

**Recipe Details Page**
A full recipe view showing:
- Image and title
- Ingredients and instructions
- Nutritional values (calories, protein, fat, etc.)
- Option to add the recipe to the meal plan


**Emanr**
  
**Authentication**
-SignupPage
Function:
Enables new users to create an account using Firebase services.
Includes:
Fields for name, email, and password
Email duplication check
User creation in Firebase Auth and Firestore
Password encryption using SHA256

-LoginPage
Function:
Allows users to log in using email/password or Google/Facebook authentication.
Includes:
Input validation for email and password
Firebase Auth integration
Fetching userId from Firestore
Saving session using SharedPreferences
Navigates to HomeScreen upon successful login

-ForgotPasswordDialog
Function:
A dialog box that allows users to reset their password.
Includes:
Email input only
Sends a reset password link using Firebase Auth
Displays success or error messages via SnackBar

**Home Screen**
-HomeScreen
Function:
Main dashboard displayed after user login.
Includes:
Displays current date and greeting
Shows remaining daily calories via a radial gauge
Fetches personalized meal suggestions from API
Displays protein, carbs, and fat using calculated values from a custom widget


**Splash1 Screen**
-Splash1 Screen
Function:
The initial welcome screen shown when the app launches for the first time.
Includes:
Display of the CookMate app logo
A short description: "Personalized recipes, smart meal planning..."
A Call-to-Action button that navigates to the next screen


  
**Splash2 Screen**
-Splash2 Screen (CookingQuoteScreen)
Function:
An animated motivational quote screen layered transparently over Splash1 before login.
Includes:
Animated quote: "Cooking is an art..."
“Let’s start cooking” button that leads to the LoginPage

**saved recipes**
-SavedRecipesScreen
Function:
Displays all recipes the user has saved.
Includes:
Retrieves data from Firestore using SavedRecipeService
Category filtering (All, Breakfast, Lunch, etc.)
Navigates to detailed recipe view on tap


  
**User Profile**
-User Profile Screen
Function:
Displays and allows editing of user account details.
Includes:
Shows user's name, bio, and profile picture
Uploads profile image to Cloudinary
Updates Firestore data on edit
Displays uploaded, saved, and favorited recipes by category
Counters show the number of recipes per type
  
**NavigationBar**
-NavigationBar
Function:
Custom bottom navigation bar for page navigation.
Includes:
Navigation between Home, Saved Recipes, and Profile
Highlights the active screen using currentIndex
Icon-only design with no labels

**SessionHandler**
-SessionHandler (in Splash)
Function:
Checks for an active user session on app startup.
Includes:
Uses SharedPreferences to check for a saved userId
If found, navigates directly to HomeScreen
If not, shows Splash1 → Splash2 → LoginPage

----------------------------------------------------------------------------
## **Notifications Screen**
- **4- Run the app:**  
  `flutter run`
- **Integration:**  
  - Connected to Firebase to display user-specific notifications.

---

## **Favorites Page**
- **4- Run the app:**  
  `flutter run`
- **Integration:**  
  - Displays and stores favorite recipes using the Recipe API.

---

## **Discovery Recipes Page**
- **4- Run the app:**  
  `flutter run`
- **Integration:**  
  - Integrated with the Recipe API to display a variety of recipes.  
  - Supports search and pagination for dynamic loading.

---

## **Ingredients Recipe Page**
- **4- Run the app:**  
  `flutter run`
- **Integration:**  
  - Displays recipe ingredients fetched from the Recipe API.

---

## **Steps Page**
- **4- Run the app:**  
  `flutter run`
- **Integration:**  
  - Connected to the YouTube API to display cooking step videos (if available).  
  - Shows textual preparation steps from the Recipe API.

---

## How to Run the Project
Make sure you have Flutter installed, then run:
```bash
`flutter pub get`
`flutter run`


## Team
- Hanan Zatar – Database ,Calorie Tracking ,Meal planning ,Recipe Upload ,Setting screen ,hamburger menu and Shopping List 

- Eman – Splash1 Screen, Splash2 Screen, LoginPage, SignupPage, Home Screen, Saved Recipes Screen, User Profile Screen, Forgot PasswordDialog, Session Handler (in Splash), NavigationBar

- Rahaf – Notifications Screen, Favorites Page, Discovery Recipes Page, Ingredients Recipe Page, Steps Page,recipe_details

- Dana – Settings ,Meal planning ,Calorie Tracking ,Ingredient Substitution ,Home Screen
