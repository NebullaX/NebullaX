pragma solidity >=0.7.6;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IStarNFT.sol";

contract StarNFTV3 is ERC721, IStarNFT, Ownable {
    using SafeMath for uint256;

    /* ============ Events ============ */
    event EventMinterAdded(address indexed newMinter);
    event EventMinterRemoved(address indexed oldMinter);

    /* ============ Modifiers ============ */
    /**
     * Only minter.
     */
    modifier onlyMinter() {
        require(minters[msg.sender], "must be minter");
        _;
    }

    /* ============ Enums ================ */
    /* ============ Structs ============ */
    /* ============ State Variables ============ */

    // Mint and burn star.
    mapping(address => bool) public minters;
    // Default allow transfer
    bool public transferable = true;
    // Star id to cid.
    mapping(uint256 => uint256) private _cids;

    uint256 private _starCount;
    string private _galaxyName;
    string private _galaxySymbol;

    /* ============ Constructor ============ */
    constructor() ERC721("", "") {}

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        require(transferable, "disabled");
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: caller is not approved or owner"
        );
        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        require(transferable, "disabled");
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: caller is not approved or owner"
        );
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public override {
        require(transferable, "disabled");
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: caller is not approved or owner"
        );
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view override returns (string memory) {
        return _galaxyName;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view override returns (string memory) {
        return _galaxySymbol;
    }

    /**
     * @dev Get Star NFT CID
     */
    function cid(uint256 tokenId) public view override returns (uint256) {
        return _cids[tokenId];
    }

    /* ============ External Functions ============ */
    function mint(address account, uint256 cid)
        external
        override
        onlyMinter
        returns (uint256)
    {
        _starCount++;
        uint256 sID = _starCount;

        _mint(account, sID);
        _cids[sID] = cid;
        return sID;
    }

    function mintBatch(
        address account,
        uint256 amount,
        uint256[] calldata cidArr
    ) external override onlyMinter returns (uint256[] memory) {
        uint256[] memory ids = new uint256[](amount);
        for (uint256 i = 0; i < ids.length; i++) {
            _starCount++;
            ids[i] = _starCount;
            _mint(account, ids[i]);
            _cids[ids[i]] = cidArr[i];
        }
        return ids;
    }

    function burn(address account, uint256 id) external override onlyMinter {
        require(
            _isApprovedOrOwner(_msgSender(), id),
            "ERC721: caller is not approved or owner"
        );
        _burn(id);
        delete _cids[id];
    }

    function burnBatch(address account, uint256[] calldata ids)
        external
        override
        onlyMinter
    {
        for (uint256 i = 0; i < ids.length; i++) {
            require(
                _isApprovedOrOwner(_msgSender(), ids[i]),
                "ERC721: caller is not approved or owner"
            );
            _burn(ids[i]);
            delete _cids[ids[i]];
        }
    }

    
}
