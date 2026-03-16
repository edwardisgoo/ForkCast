# ForkCast

### AI-Powered Restaurant Recommendation App

ForkCast is a mobile application that helps users decide where to eat by combining restaurant data with AI-assisted recommendations and user preference learning.

Instead of overwhelming users with hundreds of options, ForkCast narrows the choice down to a small curated set of restaurants tailored to user preferences.

The project was built as a group course project using Flutter, focusing on integrating AI services and creating a responsive mobile UI.

## Features
### AI Restaurant Recommendations

ForkCast uses Vertex AI to generate restaurant recommendations based on user preferences and contextual data.

Instead of listing dozens of options, the system presents three restaurants at a time, helping users make decisions faster.

### Natural Language Filtering

Besides normal filters like price and range, users are able to use natural language to set guidelines that the recommendation system will follow, using mainly but not limited to the comments on Google Maps

### Google Maps Integration

ForkCast integrates the Google Maps API to retrieve restaurant data including:

location

ratings

restaurant type

distance from user

comments

This ensures recommendations are location-aware and relevant.

### Swipe-Based Preference Learning

The app learns user preferences through swipe interactions:

👉 Swipe Right → user likes the restaurant

👈 Swipe Left → user dislikes the restaurant

These signals are used to improve future recommendations.

Over time, the recommendation system adapts to the user's taste.

### Blacklist System

Users can blacklist restaurants they never want to see again.

This prevents unwanted recommendations from appearing repeatedly.

## Tech Stack
### Frontend

Flutter (Dart)

### Backend Services

Firebase

### AI Integration

Google Vertex AI

### APIs

Google Maps API

## Architecture Overview

The application follows a client-driven architecture:

Mobile App (Flutter)

↓

Firebase Backend

↓

External APIs

• Google Maps API

• Vertex AI


The Flutter app handles UI and user interaction, while Firebase manages data storage and service integration.

AI recommendation logic is powered through Vertex AI models, which generate restaurant suggestions based on user inputs and interaction history.

Example Recommendation Flow

User sets filters or enters a natural language request.

Google Maps API retrieves nearby restaurant data.

Vertex AI generates restaurant recommendations.

App displays three restaurant cards.

User swipes to express preference.

Preference signals influence future recommendations.

## Installation

Clone the repository:

`git clone https://github.com/edwardisgoo/ForkCast`

Navigate to the project directory:

`cd ForkCast`

Install dependencies:

`flutter pub get`

Run the app:

`flutter run`

## Future Improvements

Improved preference learning model

Group decision mode for friends choosing restaurants

More advanced natural language understanding

UI improvements and additional filtering options

## Authors

Developed as a group course project.
