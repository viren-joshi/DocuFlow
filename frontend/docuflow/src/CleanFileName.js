function cleanFileName(input) {
  return input
    .replace(/^documents\//, '')        // Remove "documents/" prefix
    .replace(/_[^_]+$/, '');            // Remove "_<UUID>" suffix
}

export default cleanFileName;