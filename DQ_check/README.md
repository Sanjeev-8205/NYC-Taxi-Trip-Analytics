
### Duplicate Events Check:
A hard duplicate check using a composite trip signature identified approximately 0.8% exact duplicate events in the staging data. This level of duplication is consistent with upstream replay behavior and does not indicate systemic data corruption.

To ensure metric accuracy, a deduplicated staging view was created and is used as the input for all mart tables and analytical queries. The original staging table remains unchanged to preserve source data fidelity.
