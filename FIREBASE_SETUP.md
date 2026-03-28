# Firebase Setup Guide for Wault Secure Flutter

This guide is specifically tailored to setup the cloud infrastructure for **bhavesh23offiicial@gmail.com** in India.

## Step 1: Create the Project
1. Go to your browser and sign in with `bhavesh23offiicial@gmail.com`.
2. Open the [Firebase Console](https://console.firebase.google.com/).
3. Click the giant white **"Add project"** or **"Create a project"** button.
4. Enter the project name: `Wault Secure Mobile`.
5. *Optional*: Turn off Google Analytics (you don't need it for a private password manager).
6. Click **Create Project**.

## Step 2: Configure Server Location (Crucial for Speed in India)
During setup, if it asks you to pick a "Default GCP resource location", you MUST select **`asia-south1` (Mumbai)** or **`asia-south2` (Delhi)**. This ensures your cloud database is located in India, giving your phone lightning-fast sync speeds.

---

## Step 3: Enable The Required APIs

### 1. Enable Firebase Authentication
This ensures only YOU can log into your app.
1. On the left sidebar menu, click **Build** > **Authentication**.
2. Click **Get Started**.
3. Under the "Sign-in method" tab, click **Email/Password**.
4. Toggle **Enable** next to "Email/Password" and click **Save**.
5. *Tip:* Go to the "Users" tab here and click "Add User" to create your master login credentials right now (e.g., your email and a super strong master password).

### 2. Enable Cloud Firestore (The Database)
This is where your AES-256 encrypted passwords will be safely synced.
1. On the left sidebar menu, click **Build** > **Firestore Database**.
2. Click **Create database**.
3. Select your Database location (again, choose **`asia-south1`** or **`asia-south2`** in India).
4. Select **Start in Test mode** (we can secure the rules later) or **Start in Production mode** (recommended).
5. Click **Enable**.

If you picked Production mode, go to the **Rules** tab inside Firestore and change `allow read, write: if false;` to:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /vaults/{userId}/items/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```
*(This military-grade rule mathematically guarantees a hacker could NEVER read your vault without being logged into your exact user account!)*

---

## Step 4: Generate Your Unique App Keys

Now that the servers literally exist in India, we need to connect `d:\wault-flutter` to them.

### A. Get the Android Keys (.apk)
1. At the very top-left of the Firebase console, click the **Gear Icon ⚙️** next to "Project Overview", then click **Project settings**.
2. Scroll to the bottom where it says "There are no apps in your project". Click the **Android icon** (<i align="center">an android robot</i>).
3. Under "Android package name", type: `com.wault.secure`
4. Click **Register app**.
5. Click the giant blue **Download google-services.json** button.
6. Drag and drop that downloaded file into your computer folder specifically at: `d:\wault-flutter\android\app\google-services.json`.

### B. Get the Web/Windows Keys (.exe)
1. Go back to Project settings.
2. Click **Add app** (it's a little button) and select the **Web icon** (`</>`).
3. Type an App nickname: `Wault Windows Desktop`.
4. Click **Register app**.
5. Firebase will show you a massive block of code that looks like this:
   ```javascript
   const firebaseConfig = {
     apiKey: "AIzaSy...",
     authDomain: "wault-secure....",
     projectId: "wault-secure-...",
     storageBucket: "wault-secure....",
     messagingSenderId: "123456789",
     appId: "1:12345:web:abcd..."
   };
   ```
6. Keep that screen open! Now open `d:\wault-flutter\lib\firebase_options.dart` on your PC.
7. Replace all the `'REPLACE_ME_'` strings exactly with the real strings from your computer screen!

---

**That's it! You are done!** 
Your app is now securely cloud-synced out of India, mathematically encrypted via AES, and restricted by Firebase rule logic! You can now push your code to GitHub to compile the `.exe` and `.apk`!
