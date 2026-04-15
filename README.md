FAD ALA-3: Persistent Data Management (Notes App)
Project Overview

This project is an individual assignment for the Flutter Application Development (FAD) course. The primary objective is to demonstrate local data persistence by developing a Notes application that can store, retrieve, update, and delete information using SharedPreferences.

Technical Implementation

The application manages data through a structured workflow to ensure persistence:

Storage Engine:
Uses the shared_preferences plugin to write data to the device's internal storage.
Data Serialization:
Since SharedPreferences only supports simple data types, the app uses:
json.encode to convert a list of notes into a string for saving
json.decode to restore it back into a usable list
Lifecycle Management:
The app automatically triggers \_loadNotes during the initState phase to ensure the user's saved data is visible as soon as the app opens.
CRUD Operations

The application supports full data management functionality:

Create:
Users can add new notes, which are instantly appended to local storage.
Read:
The app retrieves the JSON string from the user_notes key and displays it in a ListView.
Update:
Users can modify existing notes via a bottom sheet interface.
Delete:
Notes can be removed, and the local database is updated immediately.
Output Description

The UI features a clean Teal theme and provides a user-friendly notes management experience:

Floating Action Button:
A “+” button used to open the input form.
Note Cards:
Each note is displayed in a styled card with:
Edit icon (blue)
Delete icon (red)
Real-time Persistence:
Every action (Add/Edit/Delete) triggers a save operation, ensuring data safety.

How to Run
Clone the repository

Run:

flutter pub get

to install dependencies (including shared_preferences)

Connect an Android/iOS device or emulator

Run:

flutter run
