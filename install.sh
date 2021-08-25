cabal install --overwrite-policy=always
echo "Built + Installed Haskell artifacts"
devtool typescript > frontend/src/Api.ts
echo "Generated up to date TypeScript types"
cd frontend
yarn build
cd ..
cabal clean
cabal install --overwrite-policy=always
echo "Re-compiled backend with the frontend artifacts embedded within it"
