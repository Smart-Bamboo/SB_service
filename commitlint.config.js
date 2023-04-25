module.exports = {
    extends: ['@commitlint/config-conventional'],
    ignores: [
        (message) => message.includes('Merge'),
    ],
    rules: {
        'body-max-line-length': [0],
    },
}
