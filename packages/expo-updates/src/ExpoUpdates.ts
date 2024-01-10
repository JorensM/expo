import { requireNativeModule } from 'expo-modules-core';

import { ExpoUpdatesModule } from './ExpoUpdatesModule.types';

export default requireNativeModule<ExpoUpdatesModule>('ExpoUpdates');
