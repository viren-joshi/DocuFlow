import { Amplify } from 'aws-amplify';

Amplify.configure({
  Auth: {
    region: 'us-east-1',
    userPoolId: 'us-east-1_2ArFEHjCN',
    userPoolWebClientId: '3k2pe8t1ub4hk2jsr4v8l8vtdj',
    authenticationFlowType: 'USER_PASSWORD_AUTH',
  },
});
