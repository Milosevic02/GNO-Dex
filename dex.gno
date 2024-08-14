package dex

import(
	"std"
	"strings"

	"gno.land/p/demo/ufmt"
	pusers "gno.land/p/demo/users"
	"gno.land/r/demo/foo20"
	"gno.land/r/demo/wugnot"
)

var(
	bucket = make(map[string]uint64)
	dex = std.CurrentRealm()
)

func AddLP(token1sym,token2sym string,token1amt,token2amt uint64) string{
	if token1amt == 0 || token2amt == 0{
		panic("you need to provide both tokens to the LP bucket!")
	}

	token1sym = strings.TrimSpace(token1sym)
	token2sym = strings.TrimSpace(token2sym)

	if token1sym == "" || token2sym == ""{
		panic("symbols cannot be empty")
	}

	if token1sym == token2sym {
		panic("symbols cannot be the same")
	}

	caller := std.PrevRealm().Addr()

	foo20.TransferFrom(pusers.AddressOrName(caller.String()),pusers.AddressOrName(dex.Addr().String()),token1amt)
	wugnot.TransferFrom(pusers.AddressOrName(caller.String()),pusers.AddressOrName(dex.Addr().String()),token2amt)

	bucket[token1sym] += token1amt
	bucket[token2sym] += token2amt

	return ufmt.Sprintf("deposited %d $%s & %d $%s", token1amt, token1sym, token2amt, token2sym)


}

func Swap(fromTokenSym,toTokenSym string,fromAmount uint64) string{
	fromTokenSym = strings.TrimSpace(fromTokenSym)
	toTokenSym = strings.TrimSpace(toTokenSym) 
	if fromTokenSym == "" || toTokenSym == "" {
		panic("symbols cannot be empty")
	}

	if fromTokenSym == toTokenSym {
		panic("symbols cannot be the same")
	}

	caller := std.PrevRealm().Addr()

	fromAmountInBucket := bucket[fromTokenSym]
	if fromAmountInBucket == 0 {
		panic("token to swap into does not exist in the bucket")
	}

	toAmount := fromAmount

	toAmountInBucket := bucket[toTokenSym]
	if toAmountInBucket == 0 {
		panic("token to swap into does not exist in the bucket")
	}

	if toAmountInBucket < toAmount{
		panic("not enough liquidity for the token you're swapping into")
	}

	if fromTokenSym == "foo" {
		foo20.TransferFrom(pusers.AddressOrName(caller.String()), pusers.AddressOrName(dex.Addr().String()), fromAmount)
		wugnot.TransferFrom(pusers.AddressOrName(dex.Addr().String()), pusers.AddressOrName(caller.String()), toAmount)
	} else if fromTokenSym == "wugnot" {
		wugnot.TransferFrom(pusers.AddressOrName(caller.String()), pusers.AddressOrName(dex.Addr().String()), fromAmount)
		foo20.TransferFrom(pusers.AddressOrName(dex.Addr().String()), pusers.AddressOrName(caller.String()), toAmount)
	} else {
		panic("unsupported token for swap")
	}

	bucket[fromTokenSym] += fromAmount
	bucket[toTokenSym] -= toAmount

	return ufmt.Sprintf("swapped %d $%s for %d $%s", toAmount, fromTokenSym, fromAmount, toTokenSym)
}

func Render(_ string) string{
	return ufmt.Sprintf("bucket: %d $%s & %d $%s", bucket["wugnot"], "wugnot", bucket["FOO"], "FOO")
}