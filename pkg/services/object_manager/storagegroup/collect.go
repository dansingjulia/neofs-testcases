package storagegroup

import (
	objutil "github.com/nspcc-dev/neofs-node/pkg/services/object/util"
	"github.com/nspcc-dev/neofs-sdk-go/checksum"
	cid "github.com/nspcc-dev/neofs-sdk-go/container/id"
	"github.com/nspcc-dev/neofs-sdk-go/object"
	addressSDK "github.com/nspcc-dev/neofs-sdk-go/object/address"
	oidSDK "github.com/nspcc-dev/neofs-sdk-go/object/id"
	"github.com/nspcc-dev/neofs-sdk-go/storagegroup"
	"github.com/nspcc-dev/tzhash/tz"
)

// CollectMembers creates new storage group structure and fills it
// with information about members collected via HeadReceiver.
//
// Resulting storage group consists of physically stored objects only.
func CollectMembers(r objutil.HeadReceiver, cnr *cid.ID, members []oidSDK.ID) (*storagegroup.StorageGroup, error) {
	var (
		sumPhySize uint64
		phyMembers []oidSDK.ID
		phyHashes  [][]byte
		addr       = addressSDK.NewAddress()
		sg         = storagegroup.New()
	)

	addr.SetContainerID(*cnr)

	for i := range members {
		addr.SetObjectID(members[i])

		if err := objutil.IterateAllSplitLeaves(r, addr, func(leaf *object.Object) {
			id, ok := leaf.ID()
			if !ok {
				return
			}

			phyMembers = append(phyMembers, id)
			sumPhySize += leaf.PayloadSize()
			cs, _ := leaf.PayloadHomomorphicHash()
			phyHashes = append(phyHashes, cs.Value())
		}); err != nil {
			return nil, err
		}
	}

	sumHash, err := tz.Concat(phyHashes)
	if err != nil {
		return nil, err
	}

	var cs checksum.Checksum
	tzHash := [64]byte{}
	copy(tzHash[:], sumHash)
	cs.SetTillichZemor(tzHash)

	sg.SetMembers(phyMembers)
	sg.SetValidationDataSize(sumPhySize)
	sg.SetValidationDataHash(cs)

	return sg, nil
}
