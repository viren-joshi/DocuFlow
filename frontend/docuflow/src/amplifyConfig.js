import { Amplify } from 'aws-amplify';

Amplify.configure({
  Auth: {
    region: 'us-east-1',
    userPoolId: 'us-east-1_2ArFEHjCN',
    userPoolWebClientId: '6p0rmbj1ltcbmlcrvdsc7bik29',
    authenticationFlowType: 'USER_PASSWORD_AUTH',
  },
});
