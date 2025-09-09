import React from 'react';
import { Box, Typography } from '@mui/material';

function SettingsPage() {
  return (
    <Box>
      <Typography variant="h4" component="h1" gutterBottom>
        System Settings
      </Typography>
      <Typography variant="body1">
        Configure system settings and preferences.
      </Typography>
    </Box>
  );
}

export default SettingsPage;