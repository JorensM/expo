import { UnavailabilityError } from 'expo-errors';

import ExpoImageManipulator from './ExpoImageManipulator';

import {
  Action,
  FlipType,
  ImageResult,
  SaveFormat,
  SaveOptions,
} from './ImageManipulator.types';

export async function manipulateAsync(
  uri: string,
  actions: Action[] = [],
  { format = SaveFormat.JPEG, ...rest }: SaveOptions = {},
): Promise<ImageResult> {
  if (!ExpoImageManipulator.manipulateAsync) {
    throw new UnavailabilityError('ImageManipulator', 'manipulateAsync');
  }
  if (!(typeof uri === 'string')) {
    throw new TypeError('The "uri" argument must be a string');
  }
  return await ExpoImageManipulator.manipulateAsync(uri, actions, { format, ...rest });
}

export {
  FlipType,
  SaveFormat,
};
