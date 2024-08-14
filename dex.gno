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

func Render(_ string) string{
	return ufmt.Sprintf("bucket: %d $%s & %d $%s", bucket["wugnot"], "wugnot", bucket["FOO"], "FOO")
}