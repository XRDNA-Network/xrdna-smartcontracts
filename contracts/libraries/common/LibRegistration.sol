// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;


struct RegistrationTerms {
    //registration fee
    uint256 fee;

    //time period covered by fee in days
    uint256 coveragePeriod;

    //time period before registration expires in days
    uint256 gracePeriod;
}

struct RegistrationEntry {
    RegistrationTerms terms;
    uint256 lastRenewal;
}

struct RegistrationStorage {
    //registration terms for all renewals
    mapping(bytes32 => RegistrationTerms) terms;

    //registrations with their original registration terms attached keyed by the terms type
    mapping(address => RegistrationEntry) registrations;
}

library LibRegistration {

    bytes32 public constant RegistrationStorageSlot = keccak256("_RegistrationStorage");
    
    event RegistrationTermsChanged(uint256 indexed fee, uint256 indexed coveragePeriod, uint256 indexed gracePeriod, bytes32 termsType);
    event RegistrationCreated(address indexed addr, uint256 indexed fee, uint256 indexed coveragePeriod, uint256 gracePeriod);
    event RegistrationRenewed(address indexed addr, uint256 indexed fee, uint256 indexed coveragePeriod, uint256 gracePeriod);
    event RegistrationRemoved(address indexed addr);


     /**
     * @dev Load RegistrationStorage from storage
     */
    function load() internal pure returns (RegistrationStorage storage rs) {
        bytes32 slot = RegistrationStorageSlot;
        assembly {
            rs.slot := slot
        }
    }



    /**
     * @dev Sets the registration terms for all renewals
     */
    function setTerms( bytes32 tType, RegistrationTerms memory terms) external {
        RegistrationStorage storage rs = load();
        rs.terms[tType] = RegistrationTerms({
            fee: terms.fee,
            coveragePeriod: terms.coveragePeriod * 86400,
            gracePeriod: terms.gracePeriod * 86400
        });
        emit RegistrationTermsChanged(terms.fee, terms.coveragePeriod, terms.gracePeriod, tType);
    }

    /**
     * @dev Returns the registration terms for all renewals
     */
    function getTerms(bytes32 tType) external view returns (RegistrationTerms memory) {
        RegistrationStorage storage rs = load();
        return rs.terms[tType];
    }

    /**
     * @dev Returns the registration terms for the given address
     */
    function getEntityTerms(address addr) external view returns (RegistrationTerms memory) {
        RegistrationStorage storage rs = load();
        return rs.registrations[addr].terms;
    }

    /**
     * @dev Returns the last renewal time for the given address
     */
    function getLastRenewal(address addr) external view returns (uint256) {
        RegistrationStorage storage rs = load();
        return rs.registrations[addr].lastRenewal;
    }

    /**
     * @dev Returns the expiration time for the given address
     */
    function getExpiration(address addr) external view returns (uint256) {
        RegistrationStorage storage rs = load();
        RegistrationEntry storage e = rs.registrations[addr];
        uint256 lastRenewal = e.lastRenewal;
        if (lastRenewal == 0) {
            return 0;
        }
        return lastRenewal + e.terms.coveragePeriod + e.terms.gracePeriod;
    }

    /**
     * @dev Creates a new registration for the given address
     */
    function createRegistration(bytes32 tType, address addr) external {
        RegistrationStorage storage rs = load();
        require(rs.registrations[addr].lastRenewal == 0, "LibRegistrationRenewal: Registration already exists");
        RegistrationTerms storage t = rs.terms[tType];
        rs.registrations[addr] = RegistrationEntry({
            terms: t,
            lastRenewal: block.timestamp
        });
        emit RegistrationCreated(addr, t.fee, t.coveragePeriod, t.gracePeriod);
    }

    /**
     * @dev Renews the registration for the given address
     */
    function renewRegistration(bytes32 tType, address addr) external {
        RegistrationStorage storage rs = load();
        RegistrationEntry storage e = rs.registrations[addr];
        require(e.lastRenewal > 0, "LibRegistrationRenewal: No registration found");
        RegistrationTerms storage t = rs.terms[tType];
        e.lastRenewal = block.timestamp;
        e.terms = t;
        emit RegistrationRenewed(addr, t.fee, t.coveragePeriod, t.gracePeriod);
    }

    /**
     * @dev Removes the last renewal time for the given address
     */
    function removeRegistration(address addr) external {
        RegistrationStorage storage rs = load();
        delete rs.registrations[addr];
        emit RegistrationRemoved(addr);
    }

    /**
     * @dev Returns whether the given address is currently registered
     */
    function isRegistered(address addr) external view returns (bool) {
        RegistrationStorage storage rs = load();
        return rs.registrations[addr].lastRenewal > 0;
    }

    /**
     * @dev Returns whether the given address is currently registered and has renewed within the grace period
     */
    function isActive(address addr) external view returns (bool) {
        RegistrationStorage storage rs = load();
        RegistrationEntry storage e = rs.registrations[addr];
        if (e.lastRenewal == 0) {
            return false;
        }
        uint256 expTime = e.lastRenewal + e.terms.coveragePeriod;
        return block.timestamp < expTime;
    }

    /**
     * @dev Returns whether the given address is currently registered and has not renewed within the grace period
     */
    function isInGracePeriod(address addr) external view returns (bool) {
        RegistrationStorage storage rs = load();
        RegistrationEntry storage e= rs.registrations[addr];
        if (e.lastRenewal == 0) {
            return false;
        }
        uint256 expTime = e.lastRenewal + e.terms.coveragePeriod;
        bool expired = block.timestamp >= expTime;
        return expired && block.timestamp < expTime + e.terms.gracePeriod;
    }

     /**
     * @dev Returns whether an entity can be deactivated. Entities can only be deactivated
     * if they are either expired or within the grace period
     */
    function canBeDeactivated(address addr) external view returns (bool) {
        RegistrationStorage storage rs = load();
        RegistrationEntry storage e = rs.registrations[addr];
        if (e.lastRenewal == 0) {
            return false;
        }
        uint256 expTime = e.lastRenewal + e.terms.coveragePeriod;
        return block.timestamp >= expTime;
    }

    /**
     * @dev Returns whether an entity can be removed. Entities can only be removed if they are
     * outside the grace period
     */
    function canBeRemoved(address addr) external view returns (bool) {
        RegistrationStorage storage rs = load();
        RegistrationEntry storage e = rs.registrations[addr];
        if (e.lastRenewal == 0) {
            return false;
        }
        uint256 expTime = e.lastRenewal + e.terms.coveragePeriod;
        return block.timestamp >= expTime + e.terms.gracePeriod;
    }
}