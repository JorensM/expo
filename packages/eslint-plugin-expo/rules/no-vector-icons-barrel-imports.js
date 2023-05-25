const { oxfordComma } = require('./utils/oxford-comma');

module.exports = {
  meta: {
    type: 'suggestion',
    docs: {
      description: 'enforce default import style for @expo/vector-icons',
      category: 'Stylistic Issues',
      recommended: false,
    },
    fixable: 'code',
    schema: [],
  },
  create(context) {
    const targetPackage = '@expo/vector-icons';

    return {
      ImportDeclaration(node) {
        if (node.source.value === targetPackage) {
          let importsToChange = [];
          node.specifiers.forEach((specifier) => {
            if (specifier.type === 'ImportSpecifier') {
              importsToChange.push(specifier.imported.name);
            }
          });

          if (importsToChange.length > 0) {
            // Group the new imports by their recommended source module.
            const newTextGroups = {};
            importsToChange.forEach((name) => {
              const source = `@expo/vector-icons/${name}`;
              if (!newTextGroups[source]) {
                newTextGroups[source] = [];
              }
              newTextGroups[source].push(name);
            });

            const newText = Object.keys(newTextGroups)
              .map((source) => `import ${newTextGroups[source]} from '${source}';`)
              .join('\n');

            const remainingImports = node.specifiers
              .filter((specifier) => !importsToChange.includes(specifier.imported.name))
              .map((specifier) => specifier.imported.name);

            const remainingText =
              remainingImports.length > 0
                ? `import { ${remainingImports.join(', ')} } from '${targetPackage}';`
                : '';

            context.report({
              node,
              message: `Import ${oxfordComma(importsToChange)} directly to reduce bundle size`,
              fix(fixer) {
                return [
                  fixer.replaceTextRange([node.range[0], node.range[1]], remainingText),
                  fixer.insertTextBefore(node, newText + '\n'),
                ];
              },
            });
          }
        }
      },
    };
  },
};
