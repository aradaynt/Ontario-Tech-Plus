# Ontario Tech Plus <img src="assets\logos\ModifiedOntarioTechLogo.png" width=30></img>

### Why upgrade the current app?

According to a large portion of the student population, the Ontario Tech Mobile App has various issues, we hope to improve the user experience by making it more intuitive for students to utilize. Our app allows students to add or drop courses, which will update their in app schedule. The application will give the students a centralized way to book an appointment with either their advisors, professors or TAs. Students will also be able to book any classroom on campus, whenever there isn't a course scheduled for that room. Students will be able to navigate on campus with ease with our on campus map, that gives directions to desired buildings. Our app can recommend clubs to the student based on their program, courses, and any interests they specify. The app can also generate QR codes that will only be scannable by our app, this can be used for signing into on-campus events. This is all on top of all the features the current Ontario Tech Mobile App already has.

### Key Features

- Profile
    - Registration
    - Login/Logout
    - Biometric Login (If phone has the hardware)
    - Forgot Password
    - Profile Picture (Uses ML to guarantee picture is of a face)
    - Profile detail editting
    - Student ID with student number encoded barcode
- Course Management
    - Add/Drop Course
    - View Enrolled Courses and Instructors, along with button link to canvas
    - Weekly Schedule Timetable\
- Navigation
    - Interactive Campus Map
    - Tracks user's current location and heading
    - Integration with databse for user course schedule
    - Polyline routing using OSRM API
    - Step-by-Step Directions to Selected Building
    - Demo of Step by Step Navigation: https://youtube.com/shorts/yGADXiFUeHg
- Appointments
    - Book Appointment with your Advisors
    - Book Appointments with Professors of your Courses
    - Book Appointments with Teachers Assistants for your Courses.
    - View all Appointments
    - Cancel Booked Appointment
- Book a Room
    - Book a free Classroom in any Building
    - Dynamic Booking Time Interval
    - Cancel Room Booking
- Home Screen Widget
    - User can add a widget to their homescreen that displays their next class and its information.
- QR Codes
    - Generate Special QR codes, only scannable by this app
    - Scan QR codes
- Club Recommendation
    - Recommend Clubs to user based on their program, courses, and any additional interests.
    - Recommendations given based on our own ML model.
- Themes
    - Light Mode
    - Dark Mode
    - Less Saturated Mode

### Tech Stack

- Frontend/Backend: Flutter, Dart
- Database: Supabase
- State Management: Riverpod
- Key Packages: `emailjs`, `flutter_map`, `flutter_polyline_points`, `home_widget`, `qr_flutter`, `syncfusion_flutter_barcodes`, `syncfusion_flutter_calendar`, `http`, `intl`, `encrypt`, `mobile_scanner`

### How to run

- Prerequisites: Flutter SDK, Android Studio
- Clone and Run:
```powershell
git clone https://github.com/aaronj241/OntarioTechPlus.git
cd OntarioTechPlus
flutter pub get
flutter run
```

`NOTE: you will need our .env file, our app will not work without it`

### Team Contributions

`Details of Features listed above`
|Name|Work|
|:-:|:-:|
|Arad Ayntabli|Appointments, Book a Room, Home Screen Widget, Supabase Assistance|
|Aaron James|Profile, Course Management, Supabase Setup|
|Ayaan Mustafa|Maps & Navigation|
|Sami Khan|QR Codes, Club Recommendation, Biometric Login|
|Teni Adegbite| User Interface, Themes, Menu Webpages|


### Academic Integrity

This is for a university project, specifically course `CSCI 4101U`<br>
This is an unofficial app
