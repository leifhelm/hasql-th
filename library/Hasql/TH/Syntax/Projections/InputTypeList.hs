{-|
AST traversal extracting input types.
-}
module Hasql.TH.Syntax.Projections.InputTypeList where

import Hasql.TH.Prelude
import Hasql.TH.Syntax.Ast
import qualified Hasql.TH.Syntax.Projections.PlaceholderTypeMap as PlaceholderTypeMap
import qualified Data.IntMap.Strict as IntMap

{-|
>>> import qualified Hasql.TH.Syntax.Parsing as P
>>> test = either (error . show) preparableStmt . Text.Megaparsec.parse P.preparableStmt ""

>>> test "select $1 :: INT4"
Right [Type "int4" False 0 False]

>>> test "select $1 :: int4, a + $2 :: text[]?"
Right [Type "int4" False 0 False,Type "text" False 1 True]

>>> test "select $1 :: int4, a + $2 :: text?[]?"
Right [Type "int4" False 0 False,Type "text" True 1 True]

>>> test "select $1"
Left "Placeholder $1 misses an explicit typecast"

>>> test "select $2 :: int4, $1 :: int4, $2 :: int4"
Right [Type "int4" False 0 False,Type "int4" False 0 False]

>>> test "select $1 :: int4, $1 :: text"
Left "Placeholder $1 has conflicting type annotations"

>>> test "select $2 :: int4, $2 :: text"
Left "Placeholder $2 has conflicting type annotations"

>>> test "select $3 :: int4, $1 :: int4"
Left "You've missed placeholder $2"

-}
preparableStmt :: PreparableStmt -> Either Text [Type]
preparableStmt = placeholderTypeMap <=< PlaceholderTypeMap.preparableStmt

placeholderTypeMap :: IntMap Type -> Either Text [Type]
placeholderTypeMap a = do
  zipWithM (\ a b -> if a == b then Right () else Left ("You've missed placeholder $" <> showAsText b))
    (IntMap.keys a) [1..]
  return (IntMap.elems a)
