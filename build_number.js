const { initializeApp, cert } = require('firebase-admin/app');
const { getDatabase, ServerValue } = require('firebase-admin/database');

const serviceAccount = require('./fastlane/FirebaseAPIKey.json');
const mobilePath = 'mobileApp';
const valuePath = 'build';

initialize();
incrementBuildNumber().then(processSuccess).catch(onError);

function initialize() {
  initializeApp({
    credential: cert(serviceAccount),
    databaseURL: 'https://broxus.firebaseio.com',
  });
}

async function incrementBuildNumber() {
  const ref = getDatabase().ref(mobilePath);
  await ref.update({ [valuePath]: ServerValue.increment(1) });
  return retrieveBuildNumber(ref);
}

async function retrieveBuildNumber(ref) {
  const snapshot = await ref.once('value');
  const data = snapshot.val() || {};
  return data[valuePath];
}

function processSuccess(build) {
  console.log(build);
  process.exit(0);
}

function onError(error) {
  console.error(error);
  process.exit(1); // something went wrong
}
