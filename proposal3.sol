// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract ProposalContract {

    struct Proposal {
        string title; // Title of the proposal
        string description; // Description of the proposal
        uint256 approve; // Number of approve votes
        uint256 reject; // Number of reject votes
        uint256 pass; // Number of pass votes
        uint256 total_vote_to_end; // When the total votes in the proposal reach this limit, proposal ends
        bool current_state; // This shows the current state of the proposal, meaning whether it passes or fails
        bool is_active; // This shows if others can vote on the proposal
    }

    mapping(uint256 => Proposal) public proposal_history; // Recordings of previous proposals
    uint256 public proposal_count; // Total number of proposals

    // Updated function to create a new proposal with title
    function createProposal(
        string memory _title,
        string memory _description,
        uint256 _total_vote_to_end
    ) external {
        proposal_count += 1;
        proposal_history[proposal_count] = Proposal({
            title: _title, // Store the title
            description: _description,
            approve: 0,
            reject: 0,
            pass: 0,
            total_vote_to_end: _total_vote_to_end,
            current_state: false,
            is_active: true
        });
    }

    // Function to get the details of a specific proposal
    function getProposal(uint256 _proposalId)
        external
        view
        returns (
            string memory title,
            string memory description,
            uint256 approve,
            uint256 reject,
            uint256 pass,
            uint256 total_vote_to_end,
            bool current_state,
            bool is_active
        )
    {
        Proposal memory proposal = proposal_history[_proposalId];
        return (
            proposal.title,
            proposal.description,
            proposal.approve,
            proposal.reject,
            proposal.pass,
            proposal.total_vote_to_end,
            proposal.current_state,
            proposal.is_active
        );
    }

    // Function to vote on a proposal
    function vote(uint256 _proposalId, uint256 _voteType) external {
        Proposal storage proposal = proposal_history[_proposalId];
        require(proposal.is_active, "Proposal is not active");

        if (_voteType == 1) {
            proposal.approve += 1;
        } else if (_voteType == 2) {
            proposal.reject += 1;
        } else if (_voteType == 3) {
            proposal.pass += 1;
        } else {
            revert("Invalid vote type");
        }

        // Check if the total votes reached the limit
        uint256 total_votes = proposal.approve + proposal.reject + proposal.pass;
        if (total_votes >= proposal.total_vote_to_end) {
            proposal.is_active = false;
            // New proposal state logic
            uint256 total_votes_cast = proposal.approve + proposal.reject + proposal.pass;
            uint256 approve_percentage = (proposal.approve * 100) / total_votes_cast;

            // Proposal succeeds if approve votes are at least 50% of total votes and more than both reject and pass votes combined
            if (approve_percentage >= 50 && proposal.approve > (proposal.reject + proposal.pass)) {
                proposal.current_state = true; // Proposal is successful
            } else {
                proposal.current_state = false; // Proposal failed
            }
        }
    }
}
