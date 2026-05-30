// Shared utilities for Zustand stores.
// All stores persist to localStorage under `niyam:v1:<slice>` with an envelope
// `{ version, state }`. Each slice owns its own migration ladder.

export const STORAGE_PREFIX = 'niyam:v1';
export const storageKey = (slice: string) => `${STORAGE_PREFIX}:${slice}`;
