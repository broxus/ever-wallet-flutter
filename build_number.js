const admin = require('firebase-admin');
const database = require('firebase/database');

const serviceAccount = require('./fastlane/FirebaseAPIKey.json');
const mobilePath = 'mobileApp';
const valuePath = 'build';

initialize();
incrementBuildNumber();

function initialize() {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: 'https://broxus.firebaseio.com',
  });
}

function incrementBuildNumber() {
  admin
    .database()
    .ref(mobilePath)
    .update({ [valuePath]: database.increment(1) })
    .then(() => {
      retrieveBuildNumber((build) => {
        console.log(build);
        process.exit(0);
      });
    })
    .catch(onError);
}

function retrieveBuildNumber(onGetData) {
  admin
    .database()
    .ref(mobilePath)
    .once('value', (snapshot) => {
      build = snapshot.val()[valuePath];
      onGetData(build);
    })
    .catch(onError);
}

function onError(error) {
  console.error(error);
  process.exit(1); // something went wrong
}
