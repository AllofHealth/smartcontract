// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AllofHealthContract {
    address public admin;
    uint public hospitalCount;
    uint public doctorCount;
    uint public pharmacistCount;
    uint public patientCount;
    uint public patientFamilyMemberCount;
    uint public patientMedicalRecordCount;
    uint public patientMedicalRecordApprovalsCount;

    function addressToString(address _address) internal pure returns (string memory) {
    bytes32 _bytes = bytes32(uint256(uint160(_address)));
    bytes memory HEX = "0123456789ABCDEF";
    bytes memory _string = new bytes(42);
    _string[0] = "0";
    _string[1] = "x";
    for (uint256 i = 0; i < 20; i++) {
        _string[2+i*2] = HEX[uint8(_bytes[i + 12] >> 4)];
        _string[3+i*2] = HEX[uint8(_bytes[i + 12] & 0x0f)];
    }
    return string(_string);
}
    
    // Define structs for each entity
    struct SystemAdmin {
        address metamaskID;
        string fullName;
        string email;
    }

    struct Hospital {
        uint hospitalID;
        address hospitalAdminWalletAddress;
        string hospitalname;
        string hospitaladdress;
        string city;
        string phone;
        string email;
        string regNo;
        bool approvalStatus;
    }

  

    struct Doctor {
        uint doctorID;
        string doctorsname;
        string specialty;
        string homeaddress;
        string city;
        string phone;
        string email;
        address walletAddress;
        uint hospitalID;
        bool approvalStatus;
    }

    struct Pharmacist {
        uint pharmacistID;
        string pharmacistname;
        string pharmacistaddress;
        string city;
        string phone;
        string email;
        address walletAddress;
        uint hospitalID;
        bool approvalStatus;
    }

    struct Patient {
        uint patientID;
        address walletAddress;
        string patientname;
        string patientaddress;
        string city;
        string phone;
        string bloodGroup;
        string genotype;
        string[] allergies;
    }

    struct PatientFamilyMember {
        uint patientID;
        uint principalPatientID;
        string memberName;
        string relationship;
        string familymemberaddress;
        string phone;
        string bloodGroup;
        string genotype;
        string[] allergies;
    }

    struct PatientMedicalRecord {
        uint recordID;
        address patientwalletAddress;
        uint patientID;
        string diagnosis;
        string recordDetailsUrl;
        string recordImagesUrl;
    }

    struct PatientMedicalRecordApprovals {
        uint approvalID;
        uint medicalRecordID;
        address approvedwalletAddress;
        string approvalType; // View/Modify
        uint approvalDurationInMinutes;
        uint expirationTime;
        
    }

    // Mapping for each entity
    mapping(string => SystemAdmin) public systemAdmins;
    mapping(uint => Hospital) public hospitals;
    mapping(uint => Doctor) public doctors;
    mapping(uint => Pharmacist) public pharmacists;
    mapping(uint => Patient) public patients;
    mapping(uint => PatientFamilyMember) public patientFamilyMembers;
    mapping(uint => PatientMedicalRecord) public patientMedicalRecords;
    mapping(uint => PatientMedicalRecordApprovals) public patientMedicalRecordApprovals;

    // Events to log important actions
    event HospitalCreated(address hospitalAdminWalletAddress, string name, string regNo);
    event AdminAdded(string metamaskID, string fullName, string email);
    event DoctorAdded( string doctorsname, string specialty, bool approvalStatus);
    event PharmacistAdded(string pharmacistname, bool approvalStatus);
    event PatientRegistered(address walletAddress, string name);
    event PatientMedicalRecordAdded( address patientwalletAddress, string diagnosis);

    // Errors
    error Unauthorized();
    error HospitalNotApproved();
     error DoctorNotApproved();
    error OnlyAdminAllowed();
    error OnlySystemAdminAllowed();
    error RecordNotFound();

    // Modifier to check if the caller is the admin
    modifier onlyAdmin() {
        if (msg.sender != admin) {
            revert OnlyAdminAllowed();
        }
        _;
    }

    // Modifier to check if the caller is the system admin
    modifier onlySystemAdmin() {
        if (keccak256(abi.encodePacked(systemAdmins[addressToString(msg.sender)].metamaskID)) != keccak256(abi.encodePacked(msg.sender))) {
            revert OnlySystemAdminAllowed();
        }
        _;
    }

    // Modifier to check if the hospital is approved
    modifier onlyApprovedHospital(uint hospitalID) {
        if (!hospitals[hospitalID].approvalStatus) {
            revert HospitalNotApproved();
        }
        _;
    }

     // Modifier to check if the doctor is approved
    modifier onlyApprovedDoctor(uint doctorID) {
        if (!doctors[doctorID].approvalStatus) {
            revert DoctorNotApproved();
        }
        _;
    }

     // Constructor to set the admin as the caller's address
    constructor() {
        admin = msg.sender;
    }

    // Function to add a hospital by the system admin
    function registerHospital(    
        string memory hospitalname,
        string memory hospitalAddress,
        string memory city,
        string memory phone,
        string memory email,
        string memory regNo
    ) external onlySystemAdmin {
        hospitalCount++;
        uint hospitalID = hospitalCount;
        hospitals[hospitalID] = Hospital({
            hospitalID: hospitalID,
            hospitalAdminWalletAddress: msg.sender,
            hospitalname: hospitalname,
            hospitaladdress: hospitalAddress,
            city: city,
            phone: phone,
            email: email,
            regNo: regNo,
            approvalStatus: false
        });
        emit HospitalCreated(msg.sender, hospitalname, regNo);
    }

    // Function to approve a hospital
    function approveHospital(uint hospitalID) external onlySystemAdmin onlyAdmin {
        hospitals[hospitalID].approvalStatus = true;
    }

    // Function to add a system admin
    function addSystemAdmin(
        address metamaskID,
        string memory fullName,
        string memory email
    ) external onlyAdmin {
        string memory metamaskIDString = addressToString(metamaskID);
        systemAdmins[metamaskIDString] = SystemAdmin({
            metamaskID: metamaskID,
            fullName: fullName,
            email: email
        });
        emit AdminAdded(metamaskIDString, fullName, email);
    }

    // Function to add a doctor
    function registerDoctor(
        string memory doctorsname,
        string memory specialty,
        string memory homeAddress,
        string memory city,
        string memory phone,
        string memory email,
        bool approvalStatus,
        uint hospitalID
    ) external onlyApprovedHospital(hospitalID) {
        doctorCount++;
        uint doctorID = doctorCount;
        doctors[doctorID] = Doctor({
            doctorID: doctorID,
            doctorsname: doctorsname,
            specialty: specialty,
            homeaddress: homeAddress,
            city: city,
            phone: phone,
            email: email,
            walletAddress: msg.sender,
            hospitalID: hospitalID,
            approvalStatus: false
        });
        emit DoctorAdded( doctorsname, specialty, approvalStatus);
    }

     // Function to approve a Doctor by an Approved Hospital
    function approveDoctor(uint doctorID, uint hospitalID) external onlyApprovedHospital(hospitalID) {
        doctors[doctorID].approvalStatus = true;
    }

    // Function to add a pharmacist
    function registerPharmacist(
        string memory pharmacistname,
        string memory pharmacistAddress,
        string memory city,
        string memory phone,
        string memory email,
        uint hospitalID
    ) external onlyApprovedHospital(hospitalID) {
        pharmacistCount++;
        uint pharmacistID = pharmacistCount;
        pharmacists[pharmacistID] = Pharmacist({
            pharmacistID: pharmacistID,
            pharmacistname: pharmacistname,
            pharmacistaddress: pharmacistAddress,
            city: city,
            phone: phone,
            email: email,
            walletAddress: msg.sender,
            hospitalID: hospitalID,
            approvalStatus: false
        });
        emit PharmacistAdded(pharmacistname, false);
    }

      // Function to approve a Pharmacist by an Approved Hospital
    function approvePharmacist(uint pharmacistID, uint hospitalID) external onlyApprovedHospital(hospitalID) {
        pharmacists[pharmacistID].approvalStatus = true;
        
    }

    // Function to register a patient
    function registerPatient(      
        string memory patientname,
        string memory patientAddress,
        string memory city,
        string memory phone,
        string memory bloodGroup,
        string memory genotype,
        string[] memory allergies
    ) external {
        patientCount++;
        uint patientID = patientCount;
        patients[patientID] = Patient({
            patientID: patientID,
            walletAddress: msg.sender,
            patientname: patientname,
            patientaddress:patientAddress,
            city: city,
            phone: phone,
            bloodGroup: bloodGroup,
            genotype: genotype,
            allergies: allergies
        });
        emit PatientRegistered(msg.sender, patientname);
    }

    // Function to add a family member to a patient
    function addPatientFamilyMember(
        uint principalPatientID,
        string memory memberName,
        string memory relationship,
        string memory familyAddress,
        string memory phone,
        string memory bloodGroup,
        string memory genotype,
        string[] memory allergies
    ) external {
        uint patientID = patientFamilyMemberCount + 1;
        patientFamilyMembers[patientID] = PatientFamilyMember({
            patientID: patientID,
            principalPatientID: principalPatientID,
            memberName: memberName,
            relationship: relationship,
            familymemberaddress: familyAddress,
            phone: phone,
            bloodGroup: bloodGroup,
            genotype: genotype,
            allergies: allergies
        });
        patientFamilyMemberCount++;
    }

    // Function to add a patient medical record
    function addPatientMedicalRecord(
        uint doctorID,
        address patientwalletAddress,
        uint patientID,
        string memory diagnosis,
        string memory recordDetailsUrl,
        string memory recordImagesUrl
    ) external onlyApprovedDoctor(doctorID) {
          patientMedicalRecordCount++;
          uint recordID = patientMedicalRecordCount;
            patientMedicalRecords[recordID] = PatientMedicalRecord({
            recordID: recordID,
            patientwalletAddress: patientwalletAddress,
            patientID: patientID,
            diagnosis: diagnosis,
            recordDetailsUrl: recordDetailsUrl,
            recordImagesUrl: recordImagesUrl
        });
        emit PatientMedicalRecordAdded( patientwalletAddress, diagnosis);
    }

    // Function to approve a medical record access for a doctor or pharmacist
    function approveMedicalRecordAccess(
        uint medicalRecordID,
        address approvedwalletAddress,
        string memory approvalType,
        uint approvalDurationInMinutes
    ) external {
         require(patientMedicalRecords[medicalRecordID].recordID != 0, "Record not found");
        uint approvalID = patientMedicalRecordApprovalsCount + 1;
         uint expirationTime = block.timestamp + (approvalDurationInMinutes * 1 minutes);

        patientMedicalRecordApprovals[approvalID] = PatientMedicalRecordApprovals({
            approvalID: approvalID,
            medicalRecordID: medicalRecordID,
            approvedwalletAddress: approvedwalletAddress,
            approvalType: approvalType,
            approvalDurationInMinutes: approvalDurationInMinutes,
            expirationTime: expirationTime
            
        });
    }

    // Function to check if access is still valid
    function isAccessValid(uint approvalID) external view returns (bool) {
    require(approvalID <= patientMedicalRecordApprovalsCount, "Approval not found");
    return block.timestamp <= patientMedicalRecordApprovals[approvalID].expirationTime;
      }

    // Function to view a medical record if access is still valid
function viewMedicalRecord(uint medicalRecordID) external view returns (PatientMedicalRecord memory) {
    require(patientMedicalRecords[medicalRecordID].recordID != 0, "Record not found");

    uint approvalID = findApprovalID(msg.sender, medicalRecordID);
    require(approvalID != 0, "Access not approved or expired");

    require(block.timestamp <= patientMedicalRecordApprovals[approvalID].expirationTime, "Access expired");

    // Return the medical record details
    return patientMedicalRecords[medicalRecordID];
}

// Helper function to find approval ID for a given wallet address and medical record ID
function findApprovalID(address walletAddress, uint medicalRecordID) internal view returns (uint) {
    for (uint i = 1; i <= patientMedicalRecordApprovalsCount; i++) {
        if (
            patientMedicalRecordApprovals[i].approvedwalletAddress == walletAddress &&
            patientMedicalRecordApprovals[i].medicalRecordID == medicalRecordID
        ) {
            return i;
        }
    }
    return 0; // Not found
}



}
