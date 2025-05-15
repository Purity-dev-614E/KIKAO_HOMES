// Give the service worker access to Firebase Messaging.
// Note that you can only use Firebase Messaging here. Other Firebase libraries
// are not available in the service worker.
// Using the latest compatible version
importScripts('https://www.gstatic.com/firebasejs/9.22.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.22.0/firebase-messaging-compat.js');

// Initialize the Firebase app in the service worker by passing in
// your app's Firebase config object.
// https://firebase.google.com/docs/web/setup#config-object
firebase.initializeApp({
  apiKey: "AIzaSyCaFGGzoCyNfNNlf2Ors6OGpTdDUfuhkA8",
    authDomain: "kikaohomes.firebaseapp.com",
    projectId: "kikaohomes",
    storageBucket: "kikaohomes.firebasestorage.app",
    messagingSenderId: "1089380066752",
    appId: "1:1089380066752:web:107812e4abedda15c91425"
});

// Retrieve an instance of Firebase Messaging so that it can handle background
// messages.
const messaging = firebase.messaging();

// Add background message handler
messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  
  // Customize notification here
  const notificationTitle = payload.notification?.title || 'Kikao Homes Notification';
  const notificationOptions = {
    body: payload.notification?.body || 'You have a new notification',
    icon: './icons/Icon-192.png', // Use relative path
    badge: './icons/Icon-192.png',
    data: payload.data,
    actions: [
      {
        action: 'open',
        title: 'Open App'
      }
    ]
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});