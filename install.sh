cabal install --overwrite-policy=always
echo "Built + Installed Haskell artifacts"
devtool typescript > frontend/src/Api.ts
echo "Generated up to date TypeScript types"
cd frontend
yarn build
echo "Transpiled and optimized the frontend artifacts"
mkdir -p $HOME/.devtool
echo "Ensured the existence the $HOME/.devtool directory"
cp -R build/* $HOME/.devtool
echo "Copied the frontend artifacts to the $HOME/.devtool directory"
